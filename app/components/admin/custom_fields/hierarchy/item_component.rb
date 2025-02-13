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

module Admin
  module CustomFields
    module Hierarchy
      class ItemComponent < ApplicationComponent
        include OpTurbo::Streamable
        include OpPrimer::ComponentHelpers

        def initialize(item:, show_edit_form: false)
          super(item)
          @show_edit_form = show_edit_form
          @root = item.root || item.parent.root
        end

        def wrapper_uniq_by
          model.id
        end

        def short_text
          "(#{model.short})"
        end

        def show_form? = @show_edit_form || model.new_record?

        def children_count
          I18n.t("custom_fields.admin.hierarchy.subitems", count: model.children.count)
        end

        def first_item?
          model.sort_order == 0
        end

        def last_item?
          model.sort_order == model.parent.children.length - 1
        end

        def menu_items(menu)
          edit_action_item(menu)
          menu.with_divider
          add_above_action_item(menu)
          add_below_action_item(menu)
          add_sub_item_action_item(menu)
          menu.with_divider
          if !first_item?
            move_to_top_action_item(menu)
            move_up_action_item(menu)
          end
          if !last_item?
            move_down_action_item(menu)
            move_to_bottom_action_item(menu)
          end
          menu.with_divider
          deletion_action_item(menu)
        end

        private

        def edit_action_item(menu)
          menu.with_item(label: I18n.t(:button_edit),
                         tag: :a,
                         href: edit_custom_field_item_path(@root.custom_field_id, model)) do |item|
            item.with_leading_visual_icon(icon: :pencil)
          end
        end

        def add_above_action_item(menu)
          menu.with_item(
            label: I18n.t(:button_add_item_above),
            tag: :a,
            content_arguments: { data: { turbo_frame: ItemsComponent.wrapper_key } },
            href: new_child_custom_field_item_path(@root.custom_field_id, model.parent, position: model.sort_order)
          ) { _1.with_leading_visual_icon(icon: "fold-up") }
        end

        def add_below_action_item(menu)
          menu.with_item(
            label: I18n.t(:button_add_item_below),
            tag: :a,
            content_arguments: { data: { turbo_frame: ItemsComponent.wrapper_key } },
            href: new_child_custom_field_item_path(@root.custom_field_id, model.parent, position: model.sort_order + 1)
          ) { _1.with_leading_visual_icon(icon: "fold-down") }
        end

        def add_sub_item_action_item(menu)
          menu.with_item(
            label: I18n.t(:button_add_sub_item),
            tag: :a,
            content_arguments: { data: { turbo_frame: ItemsComponent.wrapper_key } },
            href: new_child_custom_field_item_path(@root.custom_field_id, model)
          ) { _1.with_leading_visual_icon(icon: "op-arrow-in") }
        end

        def move_to_top_action_item(menu)
          form_inputs = [{ name: "new_sort_order", value: 0 }]

          menu.with_item(label: I18n.t(:label_sort_highest),
                         tag: :button,
                         href: move_custom_field_item_path(@root.custom_field_id, model),
                         content_arguments: { data: { turbo_frame: ItemsComponent.wrapper_key } },
                         form_arguments: { method: :post, inputs: form_inputs }) do |item|
            item.with_leading_visual_icon(icon: "move-to-top")
          end
        end

        def move_up_action_item(menu)
          form_inputs = [{ name: "new_sort_order", value: model.sort_order - 1 }]

          menu.with_item(label: I18n.t(:label_sort_higher),
                         tag: :button,
                         href: move_custom_field_item_path(@root.custom_field_id, model),
                         content_arguments: { data: { turbo_frame: ItemsComponent.wrapper_key } },
                         form_arguments: { method: :post, inputs: form_inputs }) do |item|
            item.with_leading_visual_icon(icon: "chevron-up")
          end
        end

        def move_down_action_item(menu)
          form_inputs = [{ name: "new_sort_order", value: model.sort_order + 2 }]

          menu.with_item(label: I18n.t(:label_sort_lower),
                         tag: :button,
                         href: move_custom_field_item_path(@root.custom_field_id, model),
                         content_arguments: { data: { turbo_frame: ItemsComponent.wrapper_key } },
                         form_arguments: { method: :post, inputs: form_inputs }) do |item|
            item.with_leading_visual_icon(icon: "chevron-down")
          end
        end

        def move_to_bottom_action_item(menu)
          form_inputs = [{ name: "new_sort_order", value: model.parent.children.length + 1 }]

          menu.with_item(label: I18n.t(:label_sort_lowest),
                         tag: :button,
                         href: move_custom_field_item_path(@root.custom_field_id, model),
                         content_arguments: { data: { turbo_frame: ItemsComponent.wrapper_key } },
                         form_arguments: { method: :post, inputs: form_inputs }) do |item|
            item.with_leading_visual_icon(icon: "move-to-bottom")
          end
        end

        def deletion_action_item(menu)
          menu.with_item(label: I18n.t(:button_delete),
                         scheme: :danger,
                         tag: :a,
                         href: deletion_dialog_custom_field_item_path(custom_field_id: @root.custom_field_id, id: model.id),
                         content_arguments: { data: { controller: "async-dialog" } }) do |item|
            item.with_leading_visual_icon(icon: :trash)
          end
        end
      end
    end
  end
end
