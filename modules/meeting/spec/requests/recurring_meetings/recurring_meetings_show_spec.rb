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
require_relative "../../support/pages/recurring_meeting/show"

RSpec.describe "Recurring meetings show",
               :skip_csrf,
               type: :rails_request do
  include Redmine::I18n

  shared_let(:project) { create(:project, enabled_module_names: %i[meetings]) }
  shared_let(:user) { create(:user, member_with_permissions: { project => %i[view_meetings create_meetings edit_meetings] }) }
  shared_let(:recurring_meeting) do
    create :recurring_meeting,
           project:,
           author: user,
           start_time: Time.zone.today - 10.days + 10.hours,
           frequency: "daily"
  end

  let(:current_user) { user }
  let(:show_page) { Pages::RecurringMeeting::Show.new(recurring_meeting).with_capybara_page(page) }
  let(:request) { get recurring_meeting_path(recurring_meeting) }

  before do
    login_as(current_user)
  end

  context "when user has permissions to access" do
    it "shows the recurring meetings" do
      get recurring_meeting_path(recurring_meeting)
      expect(response).to have_http_status(:ok)
    end

    it "shows project recurring meetings" do
      get project_recurring_meeting_path(project, recurring_meeting)
      expect(response).to have_http_status(:ok)
    end

    context "when the meeting has and end_date < today" do
      before do
        recurring_meeting.update_columns(end_date: Time.zone.yesterday)
      end

      it "shows the appropriate blankslate and text" do
        request
        expect(page).to have_text "Meeting series ended"
        expect(page).to have_text "ended on #{format_date(Time.zone.yesterday)}"
      end
    end

    context "when the meeting has no end_date, but iterations" do
      before do
        recurring_meeting.update_columns(end_after: "iterations",
                                         iterations: 2,
                                         start_time: Time.zone.today - 3.days + 10.hours)
      end

      it "shows the blankslate for two days ago" do
        request
        expect(page).to have_text "Meeting series ended"
        expect(page).to have_text "ended on #{format_date(Time.zone.today - 2.days)}"
      end
    end
  end

  describe "past quick filter" do
    let!(:past_instance) { create(:structured_meeting, recurring_meeting:, start_time: 1.day.ago + 10.hours) }
    let!(:past_schedule) do
      create :scheduled_meeting,
             meeting: past_instance,
             recurring_meeting:,
             start_time: 1.day.ago + 10.hours
    end

    let!(:past_schedule_cancelled) do
      create :scheduled_meeting,
             recurring_meeting:,
             start_time: 2.days.ago + 10.hours,
             cancelled: true
    end

    it "does not show the cancelled meeting" do
      get recurring_meeting_path(recurring_meeting, direction: "past")

      expect(page).to have_text format_time(past_instance.start_time)
      expect(page).to have_no_text format_time(past_schedule_cancelled.start_time)
      expect(page).to have_no_css("li", text: "Cancelled")
    end

    context "when meeting has ended and no upcoming meetings remain" do
      before do
        recurring_meeting.update_columns(end_date: Time.zone.yesterday)
      end

      it "still shows the one past meeting (Regression #61280)" do
        get recurring_meeting_path(recurring_meeting, direction: "past")
        expect(page).to have_text format_time(past_instance.start_time)
      end
    end
  end

  describe "upcoming tab" do
    let!(:upcoming_open_meeting) do
      create(:structured_meeting, recurring_meeting:, start_time: Time.zone.today + 1.day + 10.hours, state: :open)
    end
    let!(:open_meeting) do
      create :scheduled_meeting,
             meeting: upcoming_open_meeting,
             recurring_meeting:,
             start_time: Time.zone.today + 1.day + 10.hours
    end

    let!(:cancelled_meeting) do
      create :scheduled_meeting,
             recurring_meeting:,
             start_time: Time.zone.today + 2.days + 10.hours,
             cancelled: true
    end

    it "sorts meetings into two tables based on state" do
      get recurring_meeting_path(recurring_meeting)

      content = page.find_by_id("content")
      expect(content).to have_text "Open"
      expect(content).to have_text "Planned"

      open_meeting_date = format_time(open_meeting.start_time)
      cancelled_meeting_date = format_time(cancelled_meeting.start_time)
      scheduled_meeting_date = format_time(Time.zone.today + 2.days + 10.hours)

      agenda_opened = page.find("[data-test-selector='agenda-opened-table']")
      expect(agenda_opened).to have_text open_meeting_date

      planned = page.find("[data-test-selector='planned-table']")
      expect(planned).to have_text cancelled_meeting_date
      expect(planned).to have_text scheduled_meeting_date
    end
  end

  describe "upcoming quick filter" do
    context "with a rescheduled meeting" do
      let!(:rescheduled_instance) do
        create :structured_meeting,
               recurring_meeting:,
               start_time: Time.zone.today + 2.days + 10.hours
      end
      let!(:rescheduled) do
        create :scheduled_meeting,
               meeting: rescheduled_instance,
               recurring_meeting:,
               start_time: Time.zone.today + 1.day + 10.hours
      end

      it "shows rescheduled occurrences" do
        get recurring_meeting_path(recurring_meeting)

        old_date = format_time(rescheduled.start_time)
        new_date = format_time(rescheduled_instance.start_time)
        expect(page).to have_css("li s", text: old_date)
        expect(page).to have_text("#{old_date}\n#{new_date}")
      end
    end

    context "with a cancelled meeting" do
      let!(:rescheduled) do
        create :scheduled_meeting,
               :cancelled,
               recurring_meeting:,
               start_time: Time.zone.today + 1.day + 10.hours
      end

      it "shows the cancelled occurrences" do
        get recurring_meeting_path(recurring_meeting)

        expect(page).to have_css("li", text: format_time(rescheduled.start_time))
        expect(page).to have_css("li", text: "Cancelled")
      end
    end

    context "with no scheduled meetings" do
      it "shows the next five occurrences" do
        # Assuming we're past today's occurrence
        Timecop.freeze(Time.zone.today + 11.hours) do
          get recurring_meeting_path(recurring_meeting)
        end

        (1..5).each do |date|
          expect(page).to have_text format_time(Time.zone.today + date.days + 10.hours)
        end
      end
    end
  end

  context "when user has no permissions to access" do
    let(:current_user) { create(:user) }

    it "does not show the recurring meetings" do
      get recurring_meeting_path(recurring_meeting)
      expect(response).to have_http_status(:not_found)
    end

    it "does not show project recurring meetings" do
      get project_recurring_meeting_path(project, recurring_meeting)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "Show more" do
    context "when there are more than 5 scheduled instances" do
      it "shows the footer" do
        get recurring_meeting_path(recurring_meeting)

        expect(page).to have_css("#recurring-meetings-footer-component")
      end
    end

    context "when there are 5 or fewer scheduled instances" do
      let(:recurring_meeting) do
        create :recurring_meeting,
               project:,
               author: user,
               start_time: Time.zone.today + 1.day,
               frequency: "daily",
               end_after: "iterations",
               iterations: 5
      end

      it "shows no footer" do
        get recurring_meeting_path(recurring_meeting)

        expect(page).to have_no_css("#recurring-meetings-footer-component")
      end
    end

    context "when the meeting has no end date" do
      let(:recurring_meeting) do
        create :recurring_meeting,
               project:,
               author: user,
               start_time: Time.zone.today + 1.day,
               frequency: "daily",
               end_after: "never"
      end

      it "shows footer, but no counts" do
        get recurring_meeting_path(recurring_meeting)

        expect(page).to have_text "There are more scheduled meetings"
      end
    end
  end
end
