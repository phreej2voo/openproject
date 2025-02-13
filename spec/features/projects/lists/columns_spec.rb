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

RSpec.describe "Projects lists columns", :js, with_settings: { login_required?: false } do
  shared_let(:admin) { create(:admin) }

  shared_let(:manager)   { create(:project_role, name: "Manager") }
  shared_let(:developer) { create(:project_role, name: "Developer") }

  shared_let(:custom_field) { create(:text_project_custom_field) }
  shared_let(:invisible_custom_field) { create(:project_custom_field, admin_only: true) }

  shared_let(:project) { create(:project, name: "Plain project", identifier: "plain-project") }
  shared_let(:public_project) do
    create(:project, name: "Public Pr", identifier: "public-pr", public: true) do |project|
      project.custom_field_values = { invisible_custom_field.id => "Secret CF" }
    end
  end
  shared_let(:development_project) { create(:project, name: "Development project", identifier: "development-project") }

  let(:news) { create(:news, project:) }
  let(:projects_page) { Pages::Projects::Index.new }

  include ProjectStatusHelper

  describe "column selection", with_settings: { enabled_projects_columns: %w[name created_at] } do
    # Will still receive the :view_project permission
    shared_let(:user) do
      create(:user, member_with_permissions: { project => %i(view_project_attributes),
                                               development_project => %i(view_project_attributes) })
    end

    shared_let(:integer_custom_field) { create(:integer_project_custom_field) }

    shared_let(:non_member) { create(:non_member, permissions: %i(view_project_attributes)) }

    current_user { user }

    before do
      public_project.custom_field_values = { integer_custom_field.id => 1 }
      public_project.save!
      project.custom_field_values = { integer_custom_field.id => 2 }
      project.save!
      development_project.custom_field_values = { integer_custom_field.id => 3 }
      development_project.save!

      public_project.on_track!
      project.off_track!
      development_project.at_risk!
    end

    it "allows to select columns to be displayed" do
      projects_page.visit!

      projects_page.set_columns("Name", "Status", integer_custom_field.name)

      projects_page.expect_no_columns("Public", "Description", "Project status description")

      projects_page.within_row(project) do
        expect(page)
          .to have_css(".name", text: project.name)
        expect(page)
          .to have_css(".cf_#{integer_custom_field.id}", text: 2)
        expect(page)
          .to have_css(".project_status", text: "OFF TRACK")
        expect(page)
          .to have_no_css(".created_at ")
      end

      projects_page.within_row(public_project) do
        expect(page)
          .to have_css(".name", text: public_project.name)
        expect(page)
          .to have_css(".cf_#{integer_custom_field.id}", text: 1)
        expect(page)
          .to have_css(".project_status", text: "ON TRACK")
        expect(page)
          .to have_no_css(".created_at ")
      end

      projects_page.within_row(development_project) do
        expect(page)
          .to have_css(".name", text: development_project.name)
        expect(page)
          .to have_css(".cf_#{integer_custom_field.id}", text: 3)
        expect(page)
          .to have_css(".project_status", text: "AT RISK")
        expect(page)
          .to have_no_css(".created_at ")
      end
    end
  end

  context "when using the action menu", with_settings: { enabled_projects_columns: %w[created_at name project_status] } do
    before do
      login_as(admin)
      visit projects_path
    end

    describe "moving a column" do
      it "moves the selected column one place to the left and right" do
        projects_page.expect_columns_in_order("Created on", "Name", "Status")

        # Move "Name" column to the left
        projects_page.click_table_header_to_open_action_menu("Name")
        projects_page.move_column_via_action_menu("Name", direction: :left)
        wait_for_reload

        # Name was moved left?
        projects_page.expect_columns_in_order("Name", "Created on", "Status")

        # Now move it back to the right once
        projects_page.click_table_header_to_open_action_menu("Name")
        projects_page.move_column_via_action_menu("Name", direction: :right)
        wait_for_reload

        # Original position should have been restored
        projects_page.expect_columns_in_order("Created on", "Name", "Status")

        # Looking at the leftmost column
        projects_page.click_table_header_to_open_action_menu("created_at")
        projects_page.within("#menu-created_at-overlay") do
          # It should allow us to move the column right
          expect(page)
            .to have_css("a[data-test-selector='created_at-move-col-right']", text: I18n.t(:label_move_column_right))

          # It should not allow us to move the column further left
          expect(page)
            .to have_no_css("a[data-test-selector='created_at-move-col-left']", text: I18n.t(:label_move_column_left))
        end

        # Looking at the rightmost column
        projects_page.click_table_header_to_open_action_menu("project_status")
        projects_page.within("#menu-project_status-overlay") do
          # It should allow us to move the column further left
          expect(page)
            .to have_css("a[data-test-selector='project_status-move-col-left']", text: I18n.t(:label_move_column_left))

          # It should not allow us to move the column right
          expect(page)
            .to have_no_css("a[data-test-selector='project_status-move-col-right']", text: I18n.t(:label_move_column_right))
        end
      end
    end

    describe "sorting a column",
             with_settings: { enabled_projects_columns: %w[created_at name project_status description] } do
      it "does not offer the sorting options for columns that are not sortable" do
        projects_page.expect_columns_in_order("Created on", "Name", "Status", "Description")

        projects_page.click_table_header_to_open_action_menu("Description")
        projects_page.expect_no_sorting_option_in_action_menu("Description")
      end
    end

    describe "removing a column" do
      it "removes the column from the table view" do
        projects_page.expect_columns_in_order("Created on", "Name", "Status")

        # Remove "Name" column
        projects_page.click_table_header_to_open_action_menu("Name")
        projects_page.remove_column_via_action_menu("Name")
        wait_for_reload

        # Name was removed
        projects_page.expect_columns_in_order("Created on", "Status")

        # Remove "Status" column, too
        projects_page.click_table_header_to_open_action_menu("project_status")
        projects_page.remove_column_via_action_menu("project_status")
        wait_for_reload

        # It was removed
        projects_page.expect_columns_in_order("Created on")
      end
    end

    describe "adding a column" do
      it "opens the configure view dialog" do
        projects_page.click_table_header_to_open_action_menu("Name")
        projects_page.click_add_column_in_action_menu("Name")

        # Configure view dialog was opened
        expect(page).to have_css("#op-project-list-configure-dialog")
      end
    end

    describe "filtering by column",
             with_settings: { enabled_projects_columns: %w[created_at identifier project_status] } do
      it "adds the filter for a selected column" do
        projects_page.click_table_header_to_open_action_menu("created_at")
        projects_page.expect_filter_option_in_action_menu("created_at")
        projects_page.filter_by_column_via_action_menu("created_at")

        # Filter component is visible
        expect(page).to have_select("add_filter_select")
        # Filter for column is visible and can now be specified by the user
        expect(page).to have_css(".advanced-filters--filter-name[for='created_at']")

        # The correct filter input field has focus
        expect(page.has_focus_on?(".advanced-filters--filter-value input#created_at_value")).to be(true)
      end

      it "adds the filter for a selected column that has a different filter mapped to its column" do
        projects_page.click_table_header_to_open_action_menu("project_status")
        projects_page.expect_filter_option_in_action_menu("project_status")
        projects_page.filter_by_column_via_action_menu("project_status")

        # Filter component is visible
        expect(page).to have_select("add_filter_select")
        # Filter for column is visible. Note that the filter name is different from the column attribute!
        expect(page).to have_css(".advanced-filters--filter-name[for='project_status_code']")
      end

      it "does not offer to filter if the column has no associated filter" do
        # There is no filter mapping for the identifier column: we should not get the option to filter by it
        projects_page.click_table_header_to_open_action_menu("identifier")
        projects_page.expect_no_filter_option_in_action_menu("identifier")

        # Filters have not been activated and are therefore not visible
        expect(page).to have_no_select("add_filter_select")
      end
    end
  end

  context "with life cycle columns" do
    shared_let(:life_cycle_gate) { create(:project_gate, project:, date: Date.new(2024, 12, 13)) }
    shared_let(:life_cycle_stage) do
      create(:project_stage,
             project: development_project,
             start_date: Date.new(2024, 12, 1),
             end_date: Date.new(2024, 12, 13))
    end
    shared_let(:inactive_life_cycle_gate) { create(:project_gate, project:, active: false) }
    shared_let(:inactive_life_cycle_stage) { create(:project_stage, project: development_project, active: false) }

    context "with the feature flag disabled", with_flag: { stages_and_gates: false } do
      specify "life cycle columns cannot be configured to show up" do
        login_as(admin)
        projects_page.visit!

        element_selector = "#columns-select_autocompleter ng-select.op-draggable-autocomplete--input"
        results_selector = "#columns-select_autocompleter ng-dropdown-panel .ng-dropdown-panel-items"
        projects_page.expect_no_config_columns(life_cycle_gate.name,
                                               life_cycle_stage.name,
                                               inactive_life_cycle_gate.name,
                                               inactive_life_cycle_stage.name,
                                               element_selector:,
                                               results_selector:)
      end
    end

    context "with the feature flag enabled", with_flag: { stages_and_gates: true } do
      context "with an admin" do
        before do
          login_as(admin)
          projects_page.visit!
        end

        specify "configuring life cycle column display" do
          # life cycle columns do not show up by default
          expect(page).to have_no_text(life_cycle_gate.name.upcase)
          expect(page).to have_no_text(life_cycle_stage.name.upcase)
          expect(page).to have_no_text(inactive_life_cycle_gate.name.upcase)
          expect(page).to have_no_text(inactive_life_cycle_stage.name.upcase)

          # life cycle columns show up when configured to do so
          projects_page.expect_columns("Name")
          projects_page.set_columns(life_cycle_gate.name)

          expect(page).to have_text(life_cycle_gate.name.upcase)
        end

        specify "inactive life cycle columns have no cell content" do
          col_names = [life_cycle_gate, life_cycle_stage,
                       inactive_life_cycle_gate,
                       inactive_life_cycle_stage].collect(&:name)

          projects_page.set_columns(*col_names)
          # Inactive columns are still displayed in the header:
          projects_page.expect_columns("Name", *col_names)

          gate_project = life_cycle_gate.project
          projects_page.within_row(gate_project) do
            expect(page).to have_css(".name", text: gate_project.name)
            expect(page).to have_css(".lcsd_#{life_cycle_gate.definition_id}", text: "12/13/2024")
            # life cycle assigned to other project, no text here
            expect(page).to have_css(".lcsd_#{life_cycle_stage.definition_id}", text: "")
            # inactive life cycles, no text here
            expect(page).to have_css(".lcsd_#{inactive_life_cycle_stage.definition_id}", text: "")
            expect(page).to have_css(".lcsd_#{inactive_life_cycle_gate.definition_id}", text: "")
          end

          stage_project = life_cycle_stage.project
          projects_page.within_row(stage_project) do
            expect(page).to have_css(".name", text: stage_project.name)
            expect(page).to have_css(".lcsd_#{life_cycle_stage.definition_id}", text: "12/01/2024 - 12/13/2024")
            # life cycle assigned to other project, no text here
            expect(page).to have_css(".lcsd_#{life_cycle_gate.definition_id}", text: "")
          end

          # Inactive life cycle steps never show their date values
          other_proj = inactive_life_cycle_stage.project
          projects_page.within_row(other_proj) do
            expect(page).to have_css(".lcsd_#{inactive_life_cycle_stage.definition_id}", text: "")
          end
        end
      end

      context "with a user" do
        let(:permissions) { %i(view_project) }
        let(:user) do
          create(:user, member_with_permissions: { project => permissions,
                                                   development_project => %i(view_project) })
        end

        before do
          login_as(user)
          projects_page.visit!
        end

        context "for users without view_project_stages_and_gates permission" do
          specify "life cycle columns cannot be configured to show up" do
            element_selector = "#columns-select_autocompleter ng-select.op-draggable-autocomplete--input"
            results_selector = "#columns-select_autocompleter ng-dropdown-panel .ng-dropdown-panel-items"
            projects_page.expect_no_config_columns(life_cycle_gate.name,
                                                   life_cycle_stage.name,
                                                   inactive_life_cycle_gate.name,
                                                   inactive_life_cycle_stage.name,
                                                   element_selector:,
                                                   results_selector:)
          end
        end

        context "for users with view_project_stages_and_gates permission" do
          let(:permissions) { %i(view_project view_project_stages_and_gates) }

          specify "life cycle columns show up when configured to do so" do
            projects_page.expect_columns("Name")
            projects_page.set_columns(life_cycle_gate.name)

            expect(page).to have_text(life_cycle_gate.name.upcase)
          end

          specify "not permitted life cycle columns have no cell content" do
            col_names = [life_cycle_gate, life_cycle_stage,
                         inactive_life_cycle_gate,
                         inactive_life_cycle_stage].collect(&:name)

            projects_page.set_columns(*col_names)
            # Inactive columns are still displayed in the header:
            projects_page.expect_columns("Name", *col_names)

            permitted_project = project
            projects_page.within_row(permitted_project) do
              expect(page).to have_css(".name", text: permitted_project.name)
              expect(page).to have_css(".lcsd_#{life_cycle_gate.definition_id}", text: "12/13/2024")
              # life cycle assigned to other project, no text here
              expect(page).to have_css(".lcsd_#{life_cycle_stage.definition_id}", text: "")
              # inactive life cycles, no text here
              expect(page).to have_css(".lcsd_#{inactive_life_cycle_stage.definition_id}", text: "")
              expect(page).to have_css(".lcsd_#{inactive_life_cycle_gate.definition_id}", text: "")
            end

            # Not permitted life cycle steps never show their date values
            not_permitted_project = development_project
            projects_page.within_row(not_permitted_project) do
              expect(page).to have_css(".lcsd_#{life_cycle_stage.definition_id}", text: "")
            end
          end
        end
      end
    end
  end
end
