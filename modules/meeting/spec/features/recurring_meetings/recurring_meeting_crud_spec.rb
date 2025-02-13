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

require_relative "../../support/pages/meetings/new"
require_relative "../../support/pages/structured_meeting/show"
require_relative "../../support/pages/recurring_meeting/show"
require_relative "../../support/pages/meetings/index"

RSpec.describe "Recurring meetings CRUD",
               :js do
  include Components::Autocompleter::NgSelectAutocompleteHelpers

  before_all do
    travel_to(Date.new(2024, 12, 1))
  end

  after(:all) do # rubocop:disable RSpec/BeforeAfterAll
    travel_back
  end

  shared_let(:project) { create(:project, enabled_module_names: %w[meetings]) }
  shared_let(:user) do
    create :user,
           lastname: "First",
           preferences: { time_zone: "Etc/UTC" },
           member_with_permissions: { project => %i[view_meetings create_meetings edit_meetings delete_meetings] }
  end
  shared_let(:other_user) do
    create(:user,
           lastname: "Second",
           member_with_permissions: { project => %i[view_meetings] })
  end
  shared_let(:no_member_user) do
    create(:user,
           lastname: "Third")
  end
  shared_let(:meeting) do
    create :recurring_meeting,
           project:,
           start_time: "2024-12-31T13:30:00Z",
           duration: 1.5,
           frequency: "weekly",
           end_after: "specific_date",
           end_date: "2025-01-15",
           author: user
  end

  let(:current_user) { user }
  let(:show_page) { Pages::RecurringMeeting::Show.new(meeting, project:) }
  let(:meetings_page) { Pages::Meetings::Index.new(project:) }

  before do
    travel_to(Date.new(2024, 12, 1))
    login_as current_user

    # Assuming the first init job has run
    RecurringMeetings::InitNextOccurrenceJob.perform_now(meeting, meeting.first_occurrence.to_time)
  end

  it "can delete a recurring meeting from the show page and return to the index page" do
    show_page.visit!

    show_page.delete_meeting_series
    show_page.within_modal "Delete meeting series" do
      check "I understand that this deletion cannot be reversed", allow_label_click: true

      click_on "Delete permanently"
    end

    expect(page).to have_current_path project_meetings_path(project)

    expect_flash(type: :success, message: "Successful deletion.")
    show_page.expect_no_meeting date: "12/31/2024 01:30 PM"
  end

  it "can use the 'Open' button" do
    show_page.visit!

    show_page.open date: "01/07/2025 01:30 PM"
    wait_for_reload

    expect(page).to have_current_path project_meeting_path(project, Meeting.last)

    show_page.visit!

    show_page.expect_no_planned_meeting date: "01/07/2025 01:30 PM"
    show_page.expect_open_meeting date: "01/07/2025 01:30 PM"
  end

  it "can cancel an occurrence from the show page" do
    show_page.visit!

    show_page.cancel_occurrence date: "12/31/2024 01:30 PM"
    show_page.within_modal "Delete meeting occurrence" do
      click_on "Delete"
    end

    expect_flash(type: :success, message: "Successful cancellation.")

    expect(page).to have_current_path(show_page.path)

    show_page.expect_no_open_meeting date: "12/31/2024 01:30 PM"
    show_page.expect_cancelled_meeting date: "12/31/2024 01:30 PM"
  end

  it "can cancel a planned occurrence from the show page" do
    show_page.visit!

    show_page.cancel_planned_occurrence date: "01/07/2025 01:30 PM"
    show_page.within_modal "Cancel meeting occurrence" do
      click_on "Cancel occurrence"
    end

    expect_flash(type: :success, message: "Successful cancellation.")

    expect(page).to have_current_path(show_page.path)

    show_page.expect_cancelled_meeting date: "01/07/2025 01:30 PM"
  end

  it "can edit the details of a recurring meeting" do
    show_page.visit!

    show_page.expect_subtitle text: "Every week on Tuesday at 01:30 PM, ends on 01/14/2025"

    show_page.edit_meeting_series
    show_page.within_modal "Edit Meeting" do
      page.select("Daily", from: "Frequency")
      meetings_page.set_start_time "11:00"
      page.select("a number of occurrences", from: "Meeting series ends")
      page.fill_in("Occurrences", with: "8")

      sleep 0.5
      click_link_or_button("Save")
    end
    wait_for_network_idle
    show_page.expect_subtitle text: "Daily at 11:00 AM, ends on 01/07/2025"
  end

  it "shows the correct actions based on status" do
    show_page.visit!

    show_page.expect_open_meeting date: "12/31/2024 01:30 PM"
    show_page.expect_open_actions date: "12/31/2024 01:30 PM"

    show_page.expect_planned_meeting date: "01/07/2025 01:30 PM"
    show_page.expect_planned_actions date: "01/07/2025 01:30 PM"

    show_page.cancel_occurrence date: "12/31/2024 01:30 PM"
    show_page.within_modal "Delete meeting occurrence" do
      click_on "Delete"
    end

    expect_flash(type: :success, message: "Successful cancellation.")

    expect(page).to have_current_path(show_page.path)

    show_page.expect_cancelled_meeting date: "12/31/2024 01:30 PM"
    show_page.expect_cancelled_actions date: "12/31/2024 01:30 PM"
  end

  context "with view permissions only" do
    let(:current_user) { other_user }

    it "does not allow to act on the recurring meeting" do
      show_page.visit!

      expect(page).to have_no_button "Open"
      show_page.expect_open_meeting date: "12/31/2024 01:30 PM"

      within("li", text: "12/31/2024 01:30 PM") do
        click_on "more-button"

        expect(page).to have_css(".ActionListItem-label", count: 1)
        expect(page).to have_css(".ActionListItem-label", text: "Download iCalendar event")

        # Close it again
        click_on "more-button"
      end

      show_page.expect_planned_meeting date: "01/07/2025 01:30 PM"
      show_page.expect_planned_meeting date: "01/14/2025 01:30 PM"

      expect(page).not_to have_test_selector "recurring-meeting-action-menu"
    end
  end
end
