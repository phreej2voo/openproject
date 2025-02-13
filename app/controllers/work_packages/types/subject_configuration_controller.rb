# frozen_string_literal: true

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

module WorkPackages
  module Types
    class SubjectConfigurationController < ApplicationController
      layout "admin"

      before_action :require_admin
      before_action :find_type, only: %i[update_subject_configuration]

      def update_subject_configuration
        form_params = params.require(:types_forms_subject_configuration_form_model)
                            .permit(:subject_configuration, :pattern)
                            .to_h

        UpdateTypeService.new(@type, current_user)
                         .call({ patterns: pattern_collection_update(form_params) }) do |call|
          call.on_success do
            redirect_to tab_path, notice: I18n.t(:notice_successful_update)
          end

          call.on_failure do
            @default_tab = "subject_configuration"
            render template: "types/edit", status: :unprocessable_entity
          end
        end
      end

      private

      def find_type
        @type = ::Type.find(params[:id])
      end

      def tab_path = edit_tab_type_path(id: @type.id, tab: :subject_configuration)

      def pattern_collection_update(form_params)
        patterns = @type.patterns.to_h.symbolize_keys

        subject_pattern =
          case form_params
          in { subject_configuration: "generated", pattern: String => blueprint }
            { subject: { blueprint:, enabled: true } }
          in { subject_configuration: "manual", pattern: String => blueprint }
            if blueprint.empty?
              # Submitting the form with an empty blueprint and manual subject configuration will
              # remove the subject pattern from the collection
              nil
            else
              { subject: { blueprint:, enabled: false } }
            end
          else
            nil
          end

        if subject_pattern.nil?
          patterns.delete(:subject)
          patterns
        else
          patterns.merge(subject_pattern)
        end
      end
    end
  end
end
