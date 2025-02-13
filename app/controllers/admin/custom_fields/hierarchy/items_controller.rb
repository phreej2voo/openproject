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
      class ItemsController < ApplicationController
        include OpTurbo::ComponentStream
        include OpTurbo::DialogStreamHelper

        layout :admin_or_frame_layout
        model_object CustomField

        before_action :require_admin, :find_model_object, :find_active_item

        menu_item :custom_fields

        # See https://github.com/hotwired/turbo-rails?tab=readme-ov-file#a-note-on-custom-layouts
        def admin_or_frame_layout
          return "turbo_rails/frame" if turbo_frame_request?

          "admin"
        end

        def index; end

        def show
          render action: :index
        end

        def new
          @new_item = ::CustomField::Hierarchy::Item.new(parent: @active_item, sort_order: params[:position])
        end

        def edit; end

        def create
          item_service
            .insert_item(**item_input)
            .either(
              lambda do |item|
                redirect_to(
                  new_child_custom_field_item_path(@custom_field, @active_item, position: item.sort_order + 1),
                  status: :see_other
                )
              end,
              lambda do |validation_result|
                add_errors_to_form(validation_result)
                render :new
              end
            )
        end

        def update
          item_service
            .update_item(item: @active_item, label: item_input[:label], short: item_input[:short])
            .either(
              lambda do |_|
                redirect_to(custom_field_item_path(@custom_field, @active_item.parent), status: :see_other)
              end,
              lambda do |validation_result|
                add_errors_to_edit_form(validation_result)
                render action: :edit
              end
            )
        end

        def move
          item_service
            .reorder_item(item: @active_item, new_sort_order: params.require(:new_sort_order))

          redirect_to(custom_field_item_path(@custom_field, @active_item.parent), status: :see_other)
        end

        def destroy
          item_service
            .delete_branch(item: @active_item)
            .either(
              ->(_) { update_via_turbo_stream(component: ItemsComponent.new(item: @active_item.parent)) },
              ->(errors) { render_error_flash_message_via_turbo_stream(message: errors.full_messages) }
            )

          respond_with_turbo_streams(&:html)
        end

        def deletion_dialog
          respond_with_dialog DeleteItemDialogComponent.new(custom_field: @custom_field, hierarchy_item: @active_item)
        end

        private

        def item_service
          ::CustomFields::Hierarchy::HierarchicalItemService.new
        end

        def item_input
          input = { parent: @active_item, label: params[:label] }
          input[:short] = params[:short] if params[:short].present?
          input[:sort_order] = params[:sort_order].to_i if params[:sort_order].present?

          input
        end

        def add_errors_to_form(validation_result)
          @new_item = ::CustomField::Hierarchy::Item.new(**item_input)
          validation_result.errors(full: true).to_h.each do |attribute, errors|
            @new_item.errors.add(attribute, errors.join(", "))
          end
        end

        def add_errors_to_edit_form(validation_result)
          @active_item.assign_attributes(**validation_result.to_h.slice(:label, :short))

          validation_result.errors(full: true).to_h.each do |attribute, errors|
            @active_item.errors.add(attribute, errors.join(", "))
          end
        end

        def find_model_object
          @object = CustomField.hierarchy_root_and_children.find(params[:custom_field_id])
          @custom_field = @object
        rescue ActiveRecord::RecordNotFound
          render_404
        end

        def find_active_item
          @active_item = if params[:id].present?
                           CustomField::Hierarchy::Item.including_children.find(params[:id])
                         else
                           @object.hierarchy_root
                         end
        rescue ActiveRecord::RecordNotFound
          render_404
        end
      end
    end
  end
end
