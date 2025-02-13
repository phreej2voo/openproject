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

class UpdateTypeService < BaseTypeService
  def call(params)
    # forbid renaming if it is a standard type
    if params[:type] && type.is_standard?
      params[:type].delete :name
    end

    super(params, {})
  end

  private

  def set_params_and_validate(params)
    # Set patterns includes a data validation before assigning the value to the attribute.
    # A validation failure should return a service call failure.
    if params[:patterns].present?
      validate_enterprise_action(params[:patterns])
      set_patterns(params[:patterns])
      return [false, type.errors] if type.errors.any?
    end

    super
  end

  def validate_enterprise_action(patterns)
    change_from_manual_to_generated = !type.patterns.subject&.enabled? && patterns.dig(:subject, :enabled)
    action = :work_package_subject_generation

    if change_from_manual_to_generated && !EnterpriseToken.allows_to?(action)
      type.errors.add(:patterns, :error_enterprise_only, action: action.to_s.titleize)
    end
  end

  def set_patterns(patterns)
    Types::Patterns::Collection
      .build(patterns:)
      .either(
        ->(collection) { type.patterns = collection },
        ->(result) do
          result.errors(full: true).messages.each do |message|
            type.errors.add(:patterns, message.text)
          end
        end
      )
  end
end
