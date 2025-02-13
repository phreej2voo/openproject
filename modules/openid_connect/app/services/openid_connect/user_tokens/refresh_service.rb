# frozen_string_literal: true

#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2024 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

module OpenIDConnect
  module UserTokens
    class RefreshService
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)

      def initialize(user:, token_exchange:)
        @user = user
        @token_exchange = token_exchange
      end

      def call(token)
        if token.refresh_token.blank?
          return exchange_instead_of_refresh(token)
        end

        json = yield refresh_token_request(token.refresh_token)

        access_token = json["access_token"]
        refresh_token = json["refresh_token"]
        return Failure("Refresh token response invalid") if access_token.blank?

        token.update!(access_token:, refresh_token:)

        Success(token)
      end

      private

      def exchange_instead_of_refresh(token)
        # We can attempt a token exchange instead of a refresh, if we previously exchanged the token.
        # For simplicity we do not consider scenarios where the original token had a wider audience,
        # because all tokens obtained through exchange in this service will have exactly one audience.
        if @token_exchange.supported? && token.audiences.size == 1
          return @token_exchange.call(token.audiences.first)
        end

        Failure("Can't refresh the access token")
      end

      def refresh_token_request(refresh_token)
        response = OpenProject.httpx
                              .basic_auth(provider.client_id, provider.client_secret)
                              .post(provider.token_endpoint, form: {
                                      grant_type: :refresh_token,
                                      refresh_token:
                                    })
        response.raise_for_status

        Success(response.json)
      rescue HTTPX::Error => e
        Failure(e)
      end

      def provider
        @user.authentication_provider
      end
    end
  end
end
