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

class Queries::Projects::Orders::LifeCycleStepOrder < Queries::Orders::Base
  self.model = Project

  validates :life_cycle_step_definition, presence: { message: I18n.t(:"activerecord.errors.messages.does_not_exist") }

  def self.key
    /\Alcsd_(\d+)\z/
  end

  def life_cycle_step_definition
    return @life_cycle_step_definition if defined?(@life_cycle_step_definition)

    @life_cycle_step_definition = Project::LifeCycleStepDefinition.find_by(id: attribute[/\Alcsd_(\d+)\z/, 1])
  end

  def available?
    life_cycle_step_definition.present? &&
      OpenProject::FeatureDecisions.stages_and_gates_active? &&
      User.current.allowed_in_any_project?(:view_project_stages_and_gates)
  end

  private

  def joins
    join = <<~SQL.squish
      LEFT JOIN (
              SELECT steps.*, steps.definition_id as def_id
              FROM project_life_cycle_steps steps
              WHERE
                steps.active = true
                AND steps.definition_id = :definition_id
                AND steps.project_id IN (#{viewable_project_ids.to_sql})
            ) #{subquery_table_name} ON #{subquery_table_name}.project_id = projects.id
    SQL

    ActiveRecord::Base.sanitize_sql([join, { definition_id: life_cycle_step_definition.id }])
  end

  # Since we can combine multiple queries with their respective ORDER BY clauses, we need to make sure
  # that the names of our tables are unique. It suffices to include the definition id into the name as there can only
  # ever be one order statement per definition.
  def subquery_table_name
    definition_id = life_cycle_step_definition.id

    :"life_cycle_steps_subquery_#{definition_id}"
  end

  def order(scope)
    with_raise_on_invalid do
      scope.where(order_condition)
           .order(*order_by_start_and_end_date)
    end
  end

  # Ensure that only life cycle columns viewable to the current user are considered
  # for ordering the query result.
  def viewable_project_ids
    Project.allowed_to(User.current, :view_project_stages_and_gates).select(:id)
  end

  def order_condition
    # To avoid SQL injection warnings, we use Arel to build the condition.
    # Note that this SQL query uses the subquery defined in `joins`.
    steps_table = Arel::Table.new(subquery_table_name.to_s)

    # WHERE subquery_table_name.def_id = life_cycle_step_definition.id OR subquery_table_name.def_id IS NULL
    steps_table[:def_id]
      .eq(life_cycle_step_definition.id)
      .or(steps_table[:def_id].eq(nil))
  end

  def order_by_start_and_end_date
    steps_table = Arel::Table.new(subquery_table_name.to_s)

    # Even though a gate does not define an end_date, this code still works.
    [
      steps_table[:start_date].send(direction),
      steps_table[:end_date].send(direction)
    ]
  end
end
