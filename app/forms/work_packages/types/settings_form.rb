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
    class SettingsForm < ApplicationForm
      form do |settings_form|
        settings_form.text_field(
          name: :name,
          label: label(:name),
          placeholder: I18n.t(:label_name),
          input_width: :large,
          required: true,
          disabled: model.is_standard?
        )

        settings_form.color_select_list(
          name: :color_id,
          label: Color.model_name.human,
          caption: I18n.t("types.edit.settings.type_color_text"),
          input_width: :large
        )

        if show_work_flow_copy?
          settings_form.select_list(
            name: :copy_workflow_from,
            label: label(:copy_workflow_from),
            include_blank: true,
            input_width: :large
          ) do |other_types|
            work_package_types.each do |type|
              other_types.option(
                value: type.id,
                label: type.name,
                selected: type.id == prefilled_copy_workflow_from
              )
            end
          end
        end

        settings_form.rich_text_area(
          name: :description,
          label: label(:description),
          input_width: :large,
          rich_text_options: { showAttachments: false }
        )

        settings_form.check_box(
          name: :is_milestone,
          label: label(:is_milestone)
        )

        settings_form.check_box(
          name: :is_in_roadmap,
          label: label(:is_in_roadmap)
        )

        settings_form.check_box(
          name: :is_default,
          label: label(:is_default)
        )

        settings_form.submit(
          name: :submit,
          label: I18n.t(:button_save),
          scheme: :primary
        )
      end

      private

      def label(attribute)
        model.class.human_attribute_name(attribute)
      end

      def show_work_flow_copy?
        model.new_record?
      end

      def work_package_types
        Type.all
      end

      def prefilled_copy_workflow_from
        @builder.options[:copy_workflow_from]
      end
    end
  end
end
