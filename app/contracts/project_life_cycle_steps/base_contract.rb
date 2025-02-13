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

module ProjectLifeCycleSteps
  class BaseContract < ::ModelContract
    validate :select_custom_fields_permission
    validate :consecutive_steps_have_increasing_dates

    def valid?(context = :saving_life_cycle_steps) = super

    def select_custom_fields_permission
      return if user.allowed_in_project?(:edit_project_stages_and_gates, model)

      errors.add :base, :error_unauthorized
    end

    def consecutive_steps_have_increasing_dates
      # Filter out steps with missing dates before proceeding with comparison
      filtered_steps = model.available_life_cycle_steps.select(&:start_date)

      # Only proceed with comparisons if there are at least 2 valid steps
      return if filtered_steps.size < 2

      # Compare consecutive steps in pairs
      filtered_steps.each_cons(2) do |previous_step, current_step|
        if has_invalid_dates?(previous_step, current_step)
          step = previous_step.is_a?(Project::Stage) ? "Stage" : "Gate"
          field = current_step.is_a?(Project::Stage) ? :date_range : :date
          model.errors.import(
            current_step.errors.add(field, :non_continuous_dates, step:),
            attribute: :"available_life_cycle_steps.#{field}"
          )
        end
      end
    end

    private

    def start_date_for(step)
      step.start_date
    end

    def end_date_for(step)
      case step
      when Project::Gate
        step.date
      when Project::Stage
        step.end_date || step.start_date # Use the start_date as fallback for single date stages
      end
    end

    def has_invalid_dates?(previous_step, current_step)
      if previous_step.instance_of?(current_step.class)
        start_date_for(current_step) <= end_date_for(previous_step)
      else
        start_date_for(current_step) < end_date_for(previous_step)
      end
    end
  end
end
