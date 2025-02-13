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

require "spec_helper"

RSpec.describe "custom fields of type hierarchy", :js do
  let(:admin) { create(:admin) }
  let(:custom_field_index_page) { Pages::CustomFields::IndexPage.new }
  let(:new_custom_field_page) { Pages::CustomFields::NewPage.new }
  let(:hierarchy_page) { Pages::CustomFields::HierarchyPage.new }

  before do
    allow(EnterpriseToken).to receive(:allows_to?).and_return(true)
  end

  it "lets you create, update and delete a custom field of type hierarchy" do
    login_as admin

    # region CustomField creation

    custom_field_index_page.visit!

    click_on "New custom field"
    new_custom_field_page.expect_current_path

    hierarchy_name = "Stormtrooper Organisation"
    fill_in "Name", with: hierarchy_name
    select "Hierarchy", from: "Format"
    click_on "Save"

    custom_field_index_page.expect_current_path("tab=WorkPackageCustomField")
    expect(page).to have_list_item(hierarchy_name)

    # endregion

    # region Edit the details of the custom field

    CustomField.find_by(name: hierarchy_name).tap do |custom_field|
      hierarchy_page.add_custom_field_state(custom_field)
    end

    click_on hierarchy_name
    hierarchy_page.expect_current_path

    expect(page).to have_test_selector("op-custom-fields--new-hierarchy-banner")
    expect(page).to have_css(".PageHeader-title", text: hierarchy_name)

    # Now, that was the wrong name, so I can change it to the correct one
    hierarchy_name = "Imperial Organisation"
    fill_in "Name", with: "", fill_options: { clear: :backspace }
    fill_in "Name", with: hierarchy_name
    click_on "Save"
    expect(page).to have_css(".PageHeader-title", text: hierarchy_name)

    # endregion

    # region Adding items to the hierarchy

    # Now we want to create our first hierarchy items
    hierarchy_page.switch_tab "Items"
    hierarchy_page.expect_current_path
    expect(page).to have_test_selector("op-custom-fields--hierarchy-items-blankslate")

    within("sub-header") { click_on "Item" }
    expect(page).not_to have_test_selector("op-custom-fields--hierarchy-items-blankslate")
    fill_in "Label", with: "Stormtroopers"
    fill_in "Short", with: "ST"
    click_on "Save"
    expect(page).not_to have_test_selector("op-custom-fields--hierarchy-items-blankslate")
    expect(page).to have_test_selector("op-custom-fields--hierarchy-item", count: 1)
    expect(page).to have_test_selector("op-custom-fields--hierarchy-item", text: "Stormtroopers")
    expect(page).to have_test_selector("op-custom-fields--hierarchy-item", text: "(ST)")

    # And the inline form should still be there
    expect(page).to have_test_selector("op-custom-fields--new-item-form")

    # Can I add the same item again?
    fill_in "Label", with: "Stormtroopers"
    click_on "Save"
    within_test_selector("op-custom-fields--new-item-form") do
      expect(page).to have_css(".FormControl-inlineValidation", text: "Label must be unique within the same hierarchy level")
    end

    # Is the form cancelable?
    fill_in "Label", with: "Dark Troopers"
    click_on "Cancel"
    expect(page).not_to have_test_selector("op-custom-fields--new-item-form")
    expect(page).to have_test_selector("op-custom-fields--hierarchy-item", count: 1)
    expect(page).not_to have_test_selector("op-custom-fields--hierarchy-item", text: "Dark Troopers")

    # endregion

    # region Deleting items from the hierarchy

    # What happens if I added a wrong item?
    click_on "Item"
    fill_in "Label", with: "Phoenix Squad"
    click_on "Save"
    expect(page).to have_test_selector("op-custom-fields--hierarchy-item", count: 2)
    expect(page).to have_test_selector("op-custom-fields--hierarchy-item", text: "Phoenix Squad")
    hierarchy_page.open_action_menu_for("Phoenix Squad")
    click_on "Delete"
    expect(page).to have_test_selector("op-custom-fields--delete-item-dialog")
    check "I understand that this deletion cannot be reversed", allow_label_click: true
    click_on "Delete permanently"
    expect(page).not_to have_test_selector("op-custom-fields--delete-item-dialog")
    expect(page).to have_test_selector("op-custom-fields--hierarchy-item", count: 1)
    expect(page).not_to have_test_selector("op-custom-fields--hierarchy-item", text: "Phoenix Squad")

    # Can I cancel the deletion?
    hierarchy_page.open_action_menu_for("Stormtroopers")
    click_on "Delete"
    expect(page).to have_test_selector("op-custom-fields--delete-item-dialog")
    click_on "Cancel"
    expect(page).not_to have_test_selector("op-custom-fields--delete-item-dialog")
    expect(page).to have_test_selector("op-custom-fields--hierarchy-item", text: "Stormtroopers")

    # endregion

    # region Status check and cleanup

    # And is the blue banner gone, now that I have added some items?
    hierarchy_page.switch_tab "Details"
    expect(page).not_to have_test_selector("op-custom-fields--new-hierarchy-banner")

    # Finally, we delete the custom field ... I'm done with this ...
    custom_field_index_page.visit!
    expect(page).to have_list_item(hierarchy_name)
    within("tr", text: hierarchy_name) { accept_prompt { click_on "Delete" } }
    expect(page).to have_no_text(hierarchy_name)

    # endregion
  end
end
