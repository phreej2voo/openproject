# frozen_string_literal: true

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
  shared_let(:initiating_stage) { create(:project_stage_definition, name: "Initiating") }
  shared_let(:ready_to_execute_gate) { create(:project_gate_definition, name: "Ready to Execute") }
  shared_let(:executing_stage) { create(:project_stage_definition, name: "Executing") }

  let(:definitions_page) { Pages::Admin::Settings::ProjectLifeCycleStepDefinitions.new }

  context "as non admin" do
    current_user { create(:user) }

    it "does not allow the user to access the page" do
      definitions_page.visit!

      definitions_page.expect_listed([])

      definitions_page.expect_flash(message: "You are not authorized to access this page", type: :error)
    end
  end

  context "as admin without activated enterprise token" do
    current_user { create(:admin) }

    it "allows viewing definitions" do
      definitions_page.visit!

      definitions_page.expect_listed(["Initiating", "Ready to Execute", "Executing"])

      definitions_page.expect_no_controls
    end
  end

  context "as admin without feature flag", with_flag: { stages_and_gates: false } do
    current_user { create(:admin) }

    it "allows viewing definitions" do
      definitions_page.visit!

      definitions_page.expect_listed([])

      definitions_page.expect_flash(
        message: "[Error 404] The page you were trying to access doesn't exist or has been removed.",
        type: :error
      )
    end
  end

  context "as admin with activated enterprise token", with_ee: %i[customize_life_cycle] do
    current_user { create(:admin) }

    before do
      create(:color, name: "Azure", hexcode: "#0056b9")
      create(:color, name: "Gold", hexcode: "#ffd800")
    end

    it "allows managing definitions" do
      definitions_page.visit!
      definitions_page.expect_listed(["Initiating", "Ready to Execute", "Executing"])

      # filtering
      definitions_page.filter_with("ing")
      definitions_page.expect_listed(["Initiating", "Executing"])

      definitions_page.expect_no_ordering_controls

      definitions_page.clear_filter
      definitions_page.expect_listed(["Initiating", "Ready to Execute", "Executing"])

      # editing steps
      definitions_page.click_definition("Ready to Execute")
      fill_in "Name", with: "Ready to Process"
      click_on "Update"

      definitions_page.click_definition_action("Executing", action: "Edit")
      fill_in "Name", with: "Processing"
      click_on "Update"

      definitions_page.expect_listed(["Initiating", "Ready to Process", "Processing"])

      # creating steps
      definitions_page.add("Stage")
      fill_in "Name", with: "Imagining"
      definitions_page.select_color("Azure")
      click_on "Create"

      definitions_page.add("Gate")
      fill_in "Name", with: "Ready to Initiate"
      definitions_page.select_color("Gold")
      click_on "Create"

      definitions_page.expect_listed(["Initiating", "Ready to Process", "Processing", "Imagining", "Ready to Initiate"])

      # moving
      definitions_page.click_definition_action("Processing", action: "Move to bottom")
      wait_for_network_idle
      definitions_page.expect_listed(["Initiating", "Ready to Process", "Imagining", "Ready to Initiate", "Processing"])

      definitions_page.click_definition_action("Imagining", action: "Move to top")
      wait_for_network_idle
      definitions_page.expect_listed(["Imagining", "Initiating", "Ready to Process", "Ready to Initiate", "Processing"])

      definitions_page.click_definition_action("Ready to Process", action: "Move down")
      wait_for_network_idle
      definitions_page.expect_listed(["Imagining", "Initiating", "Ready to Initiate", "Ready to Process", "Processing"])

      definitions_page.click_definition_action("Ready to Initiate", action: "Move up")
      wait_for_network_idle
      definitions_page.expect_listed(["Imagining", "Ready to Initiate", "Initiating", "Ready to Process", "Processing"])

      definitions_page.drag_and_drop_list(from: 0, to: 4,
                                          elements: "[data-test-selector=project-life-cycle-step-definition]",
                                          handler: ".DragHandle")
      wait_for_network_idle
      definitions_page.expect_listed(["Ready to Initiate", "Initiating", "Ready to Process", "Processing", "Imagining"])

      definitions_page.reload!
      definitions_page.expect_listed(["Ready to Initiate", "Initiating", "Ready to Process", "Processing", "Imagining"])

      # deleting
      accept_confirm I18n.t(:text_are_you_sure_with_project_life_cycle_step) do
        definitions_page.click_definition_action("Initiating", action: "Delete")
      end
      definitions_page.expect_listed(["Ready to Initiate", "Ready to Process", "Processing", "Imagining"])
    end
  end
end
