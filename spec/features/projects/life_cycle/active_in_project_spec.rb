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

require "spec_helper"

RSpec.describe "Projects life cycle settings", :js, with_flag: { stages_and_gates: true } do
  shared_let(:project) { create(:project) }

  shared_let(:user_with_permission) do
    create(:user,
           member_with_permissions: {
             project => %w[
               select_project_life_cycle
             ]
           })
  end
  shared_let(:user_without_permission) do
    create(:user,
           member_with_permissions: {
             project => %w[
               edit_project
             ]
           })
  end

  shared_let(:initiating_stage) { create(:project_stage_definition, name: "Initiating") }
  shared_let(:ready_to_execute_gate) { create(:project_gate_definition, name: "Ready to Execute") }
  shared_let(:executing_stage) { create(:project_stage_definition, name: "Executing") }
  shared_let(:ready_to_close_gate) { create(:project_gate_definition, name: "Ready to Close") }
  shared_let(:closing_stage) { create(:project_stage_definition, name: "Closing") }

  let(:project_life_cycle_page) { Pages::Projects::Settings::LifeCycle.new(project) }

  context "with sufficient permissions" do
    current_user { user_with_permission }

    it "allows toggling the active/inactive state of lifecycle steps and filtering them" do
      project_life_cycle_page.visit!

      project_life_cycle_page.expect_listed(initiating_stage => false,
                                            ready_to_execute_gate => false,
                                            executing_stage => false,
                                            ready_to_close_gate => false,
                                            closing_stage => false)

      # Activate the stages to be found within the project
      project_life_cycle_page.toggle(initiating_stage)
      project_life_cycle_page.toggle(ready_to_close_gate)
      project_life_cycle_page.toggle(closing_stage)

      project_life_cycle_page.expect_listed(initiating_stage => true,
                                            ready_to_execute_gate => false,
                                            executing_stage => false,
                                            ready_to_close_gate => true,
                                            closing_stage => true)

      # Expect the activation state to be kept after a reload
      project_life_cycle_page.reload_with_home_page_detour

      project_life_cycle_page.expect_listed(initiating_stage => true,
                                            ready_to_execute_gate => false,
                                            executing_stage => false,
                                            ready_to_close_gate => true,
                                            closing_stage => true)

      # Disable all stages at once
      project_life_cycle_page.disable_all

      project_life_cycle_page.expect_listed(initiating_stage => false,
                                            ready_to_execute_gate => false,
                                            executing_stage => false,
                                            ready_to_close_gate => false,
                                            closing_stage => false)

      # Expect the activation state to be kept after a reload
      project_life_cycle_page.reload_with_home_page_detour

      project_life_cycle_page.expect_listed(initiating_stage => false,
                                            ready_to_execute_gate => false,
                                            executing_stage => false,
                                            ready_to_close_gate => false,
                                            closing_stage => false)

      # Enable all stages at once
      project_life_cycle_page.enable_all

      project_life_cycle_page.expect_listed(initiating_stage => true,
                                            ready_to_execute_gate => true,
                                            executing_stage => true,
                                            ready_to_close_gate => true,
                                            closing_stage => true)

      # Expect the activation state to be kept after a reload
      project_life_cycle_page.reload_with_home_page_detour

      project_life_cycle_page.expect_listed(initiating_stage => true,
                                            ready_to_execute_gate => true,
                                            executing_stage => true,
                                            ready_to_close_gate => true,
                                            closing_stage => true)

      # The user can filter the life cycle steps
      project_life_cycle_page.filter_by("ing")

      project_life_cycle_page.expect_listed(initiating_stage => true,
                                            executing_stage => true,
                                            closing_stage => true)

      project_life_cycle_page.expect_not_listed(ready_to_execute_gate,
                                                ready_to_close_gate)
    end
  end

  context "without sufficient permissions" do
    current_user { user_without_permission }

    it "does not allow the user to access the page" do
      project_life_cycle_page.visit!

      project_life_cycle_page.expect_flash(message: "You are not authorized to access this page", type: :error)
    end
  end
end
