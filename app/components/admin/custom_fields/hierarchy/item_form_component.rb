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
      class ItemFormComponent < ApplicationComponent
        include OpTurbo::Streamable

        def item_options
          options = { url:, method: http_verb, data: { test_selector: "op-custom-fields--new-item-form" } }
          options[:data][:turbo_frame] = ItemsComponent.wrapper_key if model.new_record?

          options
        end

        def http_verb
          model.new_record? ? :post : :put
        end

        def url
          if model.new_record?
            new_child_custom_field_item_path(root.custom_field_id, model.parent, position: model.sort_order)
          else
            custom_field_item_path(root.custom_field_id, model)
          end
        end

        private

        def root
          @root ||= model.new_record? ? model.parent.root : model.root
        end
      end
    end
  end
end
