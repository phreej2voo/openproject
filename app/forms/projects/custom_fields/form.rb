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
module Projects::CustomFields
  class Form < ApplicationForm
    include CustomFields::CustomFieldRendering

    form do |custom_fields_form|
      render_custom_fields(form: custom_fields_form)
    end

    def initialize(project:, custom_field_section: nil, custom_field: nil, wrapper_id: nil)
      super()
      @project = project
      @custom_field_section = custom_field_section
      @custom_field = custom_field
      @wrapper_id = wrapper_id

      if @custom_field_section.present? && @custom_field.present?
        raise ArgumentError,
              "Either custom_field_section or custom_field must be specified, but not both"
      end
    end

    # override since we want to add the model with @project
    def additional_custom_field_input_arguments
      { model: @project, wrapper_id: @wrapper_id }
    end

    private

    def custom_fields
      @custom_fields ||=
        if @custom_field.present?
          [@custom_field]
        elsif @custom_field_section.present?
          @project
            .available_custom_fields
            .where(custom_field_section_id: @custom_field_section.id)
        else
          @project.available_custom_fields
        end
    end
  end
end
