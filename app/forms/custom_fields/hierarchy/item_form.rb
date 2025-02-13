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

module CustomFields
  module Hierarchy
    class ItemForm < ApplicationForm
      form do |item_form|
        item_form.hidden name: :sort_order, value: @target_item.sort_order

        item_form.group(layout: :horizontal) do |input_group|
          input_group.text_field(
            name: :label,
            label: "Label",
            value: @target_item.label,
            visually_hide_label: true,
            required: true,
            autofocus: true,
            placeholder: I18n.t("custom_fields.admin.items.placeholder.label"),
            validation_message: validation_message_for(:label)
          )

          input_group.text_field(
            name: :short,
            label: "Short",
            value: @target_item.short,
            visually_hide_label: true,
            full_width: false,
            required: false,
            placeholder: I18n.t("custom_fields.admin.items.placeholder.short"),
            validation_message: validation_message_for(:short)
          )
        end

        item_form.group(layout: :horizontal, align_self: :end) do |button_group|
          button_group.button(name: :cancel,
                              tag: :a,
                              label: I18n.t(:button_cancel),
                              scheme: :default,
                              data: { turbo_target: "admin-custom-fields-hierarchy-items-component" },
                              href: cancel_href)
          button_group.submit(name: :submit, label: I18n.t(:button_save), scheme: :primary)
        end
      end

      # @param target_item [CustomField::Hierarchy::Item] item that will be acted upon
      def initialize(target_item:)
        super()
        @target_item = target_item
      end

      private

      def root
        @root ||= @target_item.parent.root
      end

      def cancel_href
        if @target_item.parent.root?
          url_helpers.custom_field_items_path(root.custom_field_id)
        else
          url_helpers.custom_field_item_path(root.custom_field_id, @target_item.parent)
        end
      end

      def validation_message_for(attribute)
        @target_item.errors.messages_for(attribute).to_sentence.presence
      end
    end
  end
end
