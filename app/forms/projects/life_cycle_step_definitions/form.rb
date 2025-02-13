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

module Projects::LifeCycleStepDefinitions
  class Form < ApplicationForm
    form do |f|
      f.hidden(name: :type) unless model.persisted?

      f.text_field(
        label: attribute_name(:name),
        name: :name,
        required: true,
        input_width: :medium
      )

      f.color_select_list(
        label: attribute_name(:color),
        name: :color,
        required: true,
        input_width: :medium
      )

      f.submit(
        scheme: :primary,
        name: :submit,
        label: submit_label
      )
    end

    def submit_label
      I18n.t(model.persisted? ? :button_update : :button_create)
    end
  end
end
