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

RSpec.describe "Recurring meetings complete template",
               :skip_csrf,
               type: :rails_request,
               with_settings: { date_format: "%Y-%m-%d" } do
  include Redmine::I18n

  shared_let(:project) { create(:project, enabled_module_names: %i[meetings]) }
  shared_let(:user) { create(:user, member_with_permissions: { project => %i[view_meetings create_meetings edit_meetings] }) }
  shared_let(:recurring_meeting) do
    create :recurring_meeting,
           project:,
           author: user,
           start_time: DateTime.parse("2024-12-05T10:00:00Z"),
           frequency: "daily"
  end

  let(:current_user) { user }
  let(:show_page) { Pages::RecurringMeeting::Show.new(recurring_meeting).with_capybara_page(page) }
  let(:request) do
    post end_series_recurring_meeting_path(recurring_meeting)
  end

  subject do
    Timecop.freeze("2025-01-29T10:00:00Z".to_datetime) { request }
  end

  before do
    login_as(current_user)
  end

  context "when past occurrence is already created" do
    let!(:meeting) { create(:structured_meeting, recurring_meeting:, start_time: recurring_meeting.start_time) }
    let!(:schedule) do
      create :scheduled_meeting,
             meeting:,
             recurring_meeting:,
             start_time: recurring_meeting.start_time
    end

    it "does not delete that one" do
      expect { subject }.not_to change(recurring_meeting.scheduled_meetings, :count)
      expect(response).to be_redirect

      expect(recurring_meeting.scheduled_meetings.count).to eq(1)
      first = recurring_meeting.scheduled_meetings.first.meeting
      expect(first).to eq(meeting)
    end
  end

  context "when start_time < current time" do
    let!(:meeting) { create(:structured_meeting, recurring_meeting:, start_time: recurring_meeting.start_time) }
    let!(:schedule) do
      create :scheduled_meeting,
             meeting:,
             recurring_meeting:,
             start_time: recurring_meeting.start_time
    end

    subject do
      Timecop.freeze("2024-12-04T10:00:00Z".to_datetime) { request }
    end

    it "returns an error" do
      expect { subject }.not_to change { recurring_meeting.reload.updated_at }
      expect(response).to be_redirect
      expect(flash[:error]).to include "End date must be after 2024-12-05."
    end
  end

  context "when first occurrence is cancelled" do
    let!(:schedule) do
      create :scheduled_meeting,
             :cancelled,
             recurring_meeting:,
             start_time: recurring_meeting.start_time
    end

    it "does not delete this occurrence" do
      expect { subject }.not_to change(recurring_meeting.scheduled_meetings, :count)
      expect(response).to be_redirect

      recurring_meeting.reload
      expect(recurring_meeting.end_date).to eq Date.parse("2025-01-29")

      expect(recurring_meeting.scheduled_meetings.count).to eq(1)
      first = recurring_meeting.scheduled_meetings.first
      expect(first).to be_cancelled
    end
  end

  context "when todays occurrence is present, but we're later" do
    let!(:schedule) do
      create :scheduled_meeting,
             recurring_meeting:,
             start_time: DateTime.parse("2024-12-05T10:00:00Z")
    end

    subject do
      Timecop.freeze("2024-12-05T10:01:00Z".to_datetime) { request }
    end

    it "does not delete this occurrence" do
      expect { subject }.not_to change(recurring_meeting.scheduled_meetings, :count)
      expect(response).to be_redirect

      recurring_meeting.reload
      expect(recurring_meeting.end_date).to eq Date.parse("2024-12-05")
      expect(recurring_meeting.scheduled_meetings.count).to eq(1)
    end
  end

  context "when todays occurrence is present, but we're sooner" do
    let!(:schedule) do
      create :scheduled_meeting,
             recurring_meeting:,
             start_time: DateTime.parse("2024-12-05T10:00:00Z")
    end

    subject do
      Timecop.freeze("2024-12-05T09:59:00Z".to_datetime) { request }
    end

    it "does delete this occurrence" do
      expect { subject }.to change(recurring_meeting.scheduled_meetings, :count).by(-1)
      expect(response).to be_redirect

      recurring_meeting.reload
      expect(recurring_meeting.end_date).to eq Date.parse("2024-12-05")
    end
  end

  context "when next occurrence is present" do
    let!(:schedule) do
      create :scheduled_meeting,
             recurring_meeting:,
             start_time: DateTime.parse("2024-12-06T10:00:00Z")
    end

    subject do
      Timecop.freeze("2024-12-05T10:00:00Z".to_datetime) { request }
    end

    it "does delete this occurrence" do
      expect { subject }.to change(recurring_meeting.scheduled_meetings, :count).by(-1)
      expect(response).to be_redirect

      recurring_meeting.reload
      expect(recurring_meeting.end_date).to eq Date.parse("2024-12-05")
      expect(recurring_meeting.scheduled_meetings.count).to eq(0)
      expect { schedule.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "when user has no permissions to access" do
    let(:current_user) { create(:user) }

    it "does not authorize" do
      subject
      expect(response).to have_http_status(:not_found)
    end
  end
end
