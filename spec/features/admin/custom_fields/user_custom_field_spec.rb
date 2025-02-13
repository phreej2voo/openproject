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

RSpec.describe "User custom fields edit", :js do
  shared_let(:admin) { create(:admin) }
  let(:cf_page) { Pages::CustomFields::IndexPage.new }
  let(:new_cf_page) { Pages::CustomFields::NewPage.new }

  before do
    login_as(admin)
    visit custom_fields_path
  end

  it "can create and edit user custom fields (#48725)" do
    # Create CF
    click_on "New custom field"
    new_cf_page.expect_current_path

    fill_in "Name", with: "My User CF"
    select "User", from: "Format"

    expect(page).to have_no_field("custom_field_custom_options_attributes_0_value")

    click_on "Save"

    # Expect field to be created
    cf_page.expect_current_path("tab=WorkPackageCustomField")
    expect(page).to have_list_item("My User CF")

    # Edit again
    click_on "My User CF"

    expect(page).to have_no_field("custom_field_custom_options_attributes_0_value")
    fill_in "Name", with: "My User CF (edited)"

    click_on "Save"

    # Expect field to be saved
    expect(page).to have_css(".PageHeader-title", text: "My User CF (edited)")
    cf = CustomField.last
    expect(cf.name).to eq("My User CF (edited)")
  end
end
