#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) the OpenProject GmbH
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

module Admin
  module Attachments
    class QuarantinedAttachmentsController < ApplicationController
      layout "admin"
      before_action :require_admin
      before_action :find_quarantined_attachments

      before_action :find_attachment, only: %i[destroy]

      menu_item :attachments

      def index; end

      def destroy
        container = @attachment.container
        @attachment.destroy!

        create_journal(container,
                       User.system,
                       I18n.t("antivirus_scan.deleted_by_admin", filename: @attachment.filename))

        flash[:notice] = t(:notice_successful_delete)
        redirect_to action: :index
      end

      def default_breadcrumb; end

      def show_local_breadcrumb
        false
      end

      private

      def create_journal(container, user, notes)
        ::Journals::CreateService
          .new(container, user)
          .call(notes:)
      end

      def find_quarantined_attachments
        @attachments = Attachment
          .status_quarantined
          .includes(:author, :container)
      end

      def find_attachment
        @attachment = @attachments.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_404
      end
    end
  end
end
