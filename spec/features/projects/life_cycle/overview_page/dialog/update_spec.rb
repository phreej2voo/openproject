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

require "spec_helper"
require_relative "../shared_context"

RSpec.describe "Edit project stages and gates on project overview page", :js, with_flag: { stages_and_gates: true } do
  include_context "with seeded projects and stages and gates"
  shared_let(:overview) { create :overview, project: }

  let(:overview_page) { Pages::Projects::Show.new(project) }

  current_user { admin }

  before do
    overview_page.visit_page
  end

  describe "with the dialog open" do
    context "when all LifeCycleSteps are blank" do
      before do
        Project::LifeCycleStep.update_all(start_date: nil, end_date: nil)
      end

      it "shows all the Project::LifeCycleSteps without a value" do
        dialog = overview_page.open_edit_dialog_for_life_cycles

        dialog.expect_input("Initiating", value: "", type: :stage, position: 1)
        dialog.expect_input("Ready for Planning", value: "", type: :gate, position: 2)
        dialog.expect_input("Planning", value: "", type: :stage, position: 3)
        dialog.expect_input("Ready for Executing", value: "", type: :gate, position: 4)
        dialog.expect_input("Executing", value: "", type: :stage, position: 5)
        dialog.expect_input("Ready for Closing", value: "", type: :gate, position: 6)
        dialog.expect_input("Closing", value: "", type: :stage, position: 7)

        # Saving the dialog is successful
        dialog.submit
        dialog.expect_closed

        # Sidebar displays the same empty values
        project_life_cycles.each do |life_cycle|
          overview_page.within_life_cycle_container(life_cycle) do
            expect(page).to have_text "-"
          end
        end
      end
    end

    context "when all LifeCycleSteps have a value" do
      it "shows all the Project::LifeCycleSteps and updates them correctly" do
        dialog = overview_page.open_edit_dialog_for_life_cycles

        expect_angular_frontend_initialized

        project.available_life_cycle_steps.each do |step|
          dialog.expect_input_for(step)
        end

        initiating_dates = [start_date - 1.week, start_date]

        retry_block do
          # Retrying due to a race condition between filling the input vs submitting the form preview.
          original_dates = [life_cycle_initiating.start_date, life_cycle_initiating.end_date]
          dialog.set_date_for(life_cycle_initiating, value: original_dates)

          page.driver.clear_network_traffic
          dialog.set_date_for(life_cycle_initiating, value: initiating_dates)

          dialog.expect_caption(life_cycle_initiating, text: "Duration: 8 working days")
          # Ensure that only 1 ajax request is triggered after setting the date range.
          expect(page.driver.browser.network.traffic.size).to eq(1)
        end

        ready_for_planning_date = start_date + 1.day
        dialog.set_date_for(life_cycle_ready_for_planning, value: ready_for_planning_date)
        dialog.expect_no_caption(life_cycle_ready_for_planning)

        # Saving the dialog is successful
        dialog.submit
        dialog.expect_closed

        # Sidebar is refreshed with the updated values
        expected_date_range = initiating_dates.map { |date| date.strftime("%m/%d/%Y") }.join(" - ")
        overview_page.within_life_cycle_container(life_cycle_initiating) do
          expect(page).to have_text expected_date_range
        end

        overview_page.within_life_cycle_container(life_cycle_ready_for_planning) do
          expect(page).to have_text ready_for_planning_date.strftime("%m/%d/%Y")
        end
      end

      it "shows the validation errors" do
        expect_angular_frontend_initialized
        wait_for_network_idle

        dialog = overview_page.open_edit_dialog_for_life_cycles

        expected_text = "Date can't be earlier than the previous Stage's end date."

        # Cycling is required so we always select a different date on the datepicker,
        # making sure the change event is triggered.
        cycled_days = [0, 1].cycle

        # Retrying due to a race condition between filling the input vs submitting the form preview.
        retry_block do
          value = start_date + cycled_days.next.days
          dialog.set_date_for(life_cycle_ready_for_planning, value:)

          dialog.expect_validation_message(life_cycle_ready_for_planning, text: expected_text)
        end

        # Saving the dialog fails
        dialog.submit
        dialog.expect_open

        # The validation message is kept after the unsuccessful save attempt
        dialog.expect_validation_message(life_cycle_ready_for_planning, text: expected_text)

        retry_block do
          # The validation message is cleared when date is changed
          value = start_date + 2.days + cycled_days.next.days
          dialog.set_date_for(life_cycle_ready_for_planning, value:)
          dialog.expect_no_validation_message(life_cycle_ready_for_planning)
        end

        # Saving the dialog is successful
        dialog.submit
        dialog.expect_closed
      end
    end

    context "when there is an invalid custom field on the project (Regression#60666)" do
      let(:custom_field) { create(:string_project_custom_field, is_required: true, is_for_all: true) }

      before do
        project.custom_field_values = { custom_field.id => nil }
        project.save(validate: false)
      end

      it "allows saving and closing the dialog without the custom field validation to interfere" do
        dialog = overview_page.open_edit_dialog_for_life_cycles

        expect_angular_frontend_initialized

        # Saving the dialog is successful
        dialog.submit
        dialog.expect_closed
      end
    end
  end
end
