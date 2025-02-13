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
    ##
    # Provides APIs to obtain access tokens of a given user for use at a third-party
    # application for which we know the audience name, which is typically the application's
    # client_id at an identity provider that OpenProject and the application have in common.
    class FetchService
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:access_token_for, :refreshed_access_token_for)

      def initialize(user:,
                     jwt_parser: JwtParser.new(verify_audience: false, verify_expiration: false),
                     token_exchange: ExchangeService.new(user:),
                     token_refresh: RefreshService.new(user:, token_exchange:))
        @user = user
        @token_exchange = token_exchange
        @token_refresh = token_refresh
        @jwt_parser = jwt_parser
      end

      ##
      # Obtains an access token that can be used to make requests in the user's name at the
      # remote service identified by the +audience+ parameter.
      #
      # The access token will be refreshed before being returned by this method, if it can be
      # identified as being expired. There is no guarantee that all access tokens will be properly
      # recognized as expired, so client's still need to make sure to handle rejected access tokens
      # properly. Also see #refreshed_access_token_for.
      #
      # A token exchange is attempted, if the provider supports OAuth 2.0 Token Exchange and a token
      # for the target audience either can't be found or it has expired, but has no available refresh token.
      def access_token_for(audience:)
        token = yield token_with_audience(audience)
        token = yield @token_refresh.call(token) if expired?(token.access_token)

        Success(token.access_token)
      end

      ##
      # Obtains an access token that can be used to make requests in the user's name at the
      # remote service identified by the +audience+ parameter.
      #
      # The access token will always be refreshed before being returned by this method.
      # It is advised to use this method, after learning that a remote service rejected
      # an access token, because it was expired.
      #
      # A token exchange is attempted, if the provider supports OAuth 2.0 Token Exchange and a token
      # for the target audience either can't be found or it has expired, but has no available refresh token.
      def refreshed_access_token_for(audience:)
        token = yield token_with_audience(audience)
        token = yield @token_refresh.call(token)
        Success(token.access_token)
      end

      private

      def token_with_audience(aud)
        token = @user.oidc_user_tokens.where("audiences ? :aud", aud:).first
        return Success(token) if token

        return @token_exchange.call(aud) if @token_exchange.supported?

        Failure("No token for audience '#{aud}'")
      end

      def expired?(token_string)
        exp = @jwt_parser.parse(token_string).fmap { |decoded, _| decoded["exp"] }.value_or(nil)
        return false if exp.nil?

        exp <= Time.now.to_i
      end
    end
  end
end
