# frozen_string_literal: true

# -- copyright
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
# ++

class Queries::Projects::Selects::LifeCycleStep < Queries::Selects::Base
  KEY = /\Alcsd_(\d+)\z/

  def self.key
    KEY
  end

  def self.all_available
    return [] unless available?

    Project::LifeCycleStepDefinition
      .pluck(:id)
      .map { |id| new(:"lcsd_#{id}") }
  end

  def caption
    life_cycle_step_definition.name
  end

  def life_cycle_step_definition
    return @life_cycle_step_definition if defined?(@life_cycle_step_definition)

    @life_cycle_step_definition = Project::LifeCycleStepDefinition
                                    .find_by(id: attribute[KEY, 1])
  end

  def self.available?
    OpenProject::FeatureDecisions.stages_and_gates_active? &&
    User.current.allowed_in_any_project?(:view_project_stages_and_gates)
  end

  def available?
    life_cycle_step_definition.present?
  end

  def visual_icon
    # Show the proper icon for the definition with the correct color.
    icon = case life_cycle_step_definition
           when Project::StageDefinition
             :"git-commit"
           when Project::GateDefinition
             :diamond
           else
             raise "Unknown life cycle definition for: #{life_cycle_step_definition}"
           end

    classes = helpers.hl_inline_class("life_cycle_step_definition", life_cycle_step_definition)

    { icon:, classes: }
  end

  def action_menu_classes
    "leading-visual-icon-header"
  end

  private

  def helpers
    @helpers ||= Object.new.extend(ColorsHelper)
  end
end
