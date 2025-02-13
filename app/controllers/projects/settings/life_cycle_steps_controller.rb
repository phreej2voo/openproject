# -- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2010-2024 the OpenProject GmbH
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
# ++

class Projects::Settings::LifeCycleStepsController < Projects::SettingsController
  include OpTurbo::ComponentStream

  before_action :deny_access_on_feature_flag

  before_action :load_life_cycle_definitions, only: %i[index enable_all disable_all]

  menu_item :settings_life_cycle_steps

  def index; end

  def toggle
    definition = Project::LifeCycleStepDefinition.where(id: params[:id])

    upsert_steps(definition, active: params["value"])
  end

  def disable_all
    upsert_steps(@life_cycle_definitions, active: false)

    redirect_to action: :index
  end

  def enable_all
    upsert_steps(@life_cycle_definitions, active: true)

    redirect_to action: :index
  end

  private

  def load_life_cycle_definitions
    @life_cycle_definitions = Project::LifeCycleStepDefinition.order(position: :asc)
  end

  def deny_access_on_feature_flag
    deny_access(not_found: true) unless OpenProject::FeatureDecisions.stages_and_gates_active?
  end

  def upsert_steps(definitions, active:)
    Project::LifeCycleStep.upsert_all(
      definitions.map do |definition|
        {
          project_id: @project.id,
          definition_id: definition.id,
          active:,
          type: definition.step_class
        }
      end,
      unique_by: %i[project_id definition_id]
    )
  end
end
