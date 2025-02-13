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

require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper.rb")

RSpec.describe "time entry dialog", :js, with_flag: :track_start_and_end_times_for_time_entries do
  include Redmine::I18n

  shared_let(:project) { create(:project_with_types) }

  shared_let(:work_package_a) { create(:work_package, subject: "WP A", project:) }
  shared_let(:work_package_b) { create(:work_package, subject: "WP B", project:) }

  let(:time_logging_modal) { Components::TimeLoggingModal.new }

  let(:user) { create(:user, member_with_permissions: { project => permissions }) }

  before do
    login_as user
  end

  context "when user has permission to log own time" do
    let(:permissions) { %i[log_own_time view_own_time_entries view_work_packages] }

    before do
      visit work_package_path(work_package_a)

      find("#action-show-more-dropdown-menu .button").click
      find(".menu-item", text: "Log time").click
    end

    it "does not show the user autocompleter" do
      time_logging_modal.is_visible(true)
      time_logging_modal.shows_field("user_id", false)
    end

    context "when start and end time is not allowed", with_settings: { allow_tracking_start_and_end_times: false } do
      it "does not show fields to track start and end times" do
        time_logging_modal.shows_field("start_time", false)
        time_logging_modal.shows_field("end_time", false)
        time_logging_modal.shows_field("hours", true)
      end
    end

    context "when start and end time is allowed", with_settings: { allow_tracking_start_and_end_times: true } do
      it "shows fields to track start and end times" do
        time_logging_modal.shows_field("start_time", true)
        time_logging_modal.requires_field("start_time", required: false)
        time_logging_modal.shows_field("end_time", true)
        time_logging_modal.requires_field("end_time", required: false)
        time_logging_modal.shows_field("hours", true)
      end
    end

    context "when start and end time is enforced",
            with_settings: { allow_tracking_start_and_end_times: true, enforce_tracking_start_and_end_times: true } do
      it "shows fields to track start and end times" do
        time_logging_modal.shows_field("start_time", true)
        time_logging_modal.requires_field("start_time")
        time_logging_modal.shows_field("end_time", true)
        time_logging_modal.requires_field("end_time")
        time_logging_modal.shows_field("hours", true)
      end
    end
  end

  context "when user has permission to log time for others" do
    let!(:other_user) do
      create(
        :user,
        firstname: "Max",
        lastname: "Mustermann",
        preferences: {
          time_zone: "Asia/Tokyo"
        },
        member_with_permissions: { project => [:view_project] }
      )
    end
    let(:permissions) { %i[log_time view_time_entries view_work_packages] }

    before do
      visit work_package_path(work_package_a)

      find("#action-show-more-dropdown-menu .button").click
      find(".menu-item", text: "Log time").click
    end

    it "shows the user autocompleter and prefills it with the current user" do
      time_logging_modal.is_visible(true)
      time_logging_modal.shows_field("user_id", true)
      time_logging_modal.expect_user(user)

      time_logging_modal.update_field("user_id", other_user.name)

      time_logging_modal.expect_user(other_user)
      time_logging_modal.shows_caption(I18n.t("notice_different_time_zones", tz: friendly_timezone_name(other_user.time_zone)))
    end
  end

  describe "calculating logic", with_settings: { allow_tracking_start_and_end_times: true } do
    let(:permissions) { %i[log_own_time view_own_time_entries view_work_packages] }

    before do
      visit work_package_path(work_package_a)

      find("#action-show-more-dropdown-menu .button").click
      find(".menu-item", text: "Log time").click
    end

    it "normalizes the hour input" do
      time_logging_modal.update_field("hours", "6h 45min")
      time_logging_modal.has_field_with_value("hours", "6.75h")

      time_logging_modal.update_field("hours", "4:15")
      time_logging_modal.has_field_with_value("hours", "4.25h")

      time_logging_modal.update_field("hours", "1m 2w 3d 4h 5m")
      time_logging_modal.has_field_with_value("hours", "412.1h")

      time_logging_modal.update_field("hours", "1.5")
      time_logging_modal.has_field_with_value("hours", "1.5h")

      time_logging_modal.update_field("hours", "3,7")
      time_logging_modal.has_field_with_value("hours", "3.7h")
    end

    it "calculates the hours based on the start and end time" do
      time_logging_modal.update_time_field("start_time", hour: 10, minute: 0)
      time_logging_modal.update_time_field("end_time", hour: 12, minute: 30)

      time_logging_modal.has_field_with_value("hours", "2.5h")
    end

    it "correctly handles when end_time < start_time (multiple days)" do
      time_logging_modal.update_time_field("start_time", hour: 10, minute: 0)
      time_logging_modal.update_time_field("end_time", hour: 9, minute: 45)

      time_logging_modal.has_field_with_value("hours", "23.75h")
      time_logging_modal.shows_caption("+1 day")
    end

    it "correctly handles when hours > 24" do
      time_logging_modal.update_time_field("start_time", hour: 10, minute: 0)
      time_logging_modal.update_field("hours", "50h")

      time_logging_modal.has_field_with_value("end_time", "12:00")
      time_logging_modal.shows_caption("+2 days")
    end

    it "calculates the end time based on start time and hours" do
      time_logging_modal.update_time_field("start_time", hour: 10, minute: 0)
      time_logging_modal.update_field("hours", "3h")

      time_logging_modal.has_field_with_value("end_time", "13:00")
    end

    it "calculates the start time based on end time and hours" do
      time_logging_modal.update_time_field("end_time", hour: 10, minute: 0)
      time_logging_modal.update_field("hours", "3h")

      time_logging_modal.has_field_with_value("start_time", "07:00")
    end

    it "recalculates the end time, when changing the hours field" do
      time_logging_modal.update_time_field("start_time", hour: 10, minute: 0)
      time_logging_modal.update_time_field("end_time", hour: 12, minute: 30)

      time_logging_modal.has_field_with_value("hours", "2.5h")

      time_logging_modal.update_field("hours", "6h")

      time_logging_modal.has_field_with_value("end_time", "16:00")
    end

    it "recalculates the end time, when changing the start_time field" do
      time_logging_modal.update_time_field("start_time", hour: 10, minute: 0)
      time_logging_modal.update_time_field("end_time", hour: 12, minute: 30)

      time_logging_modal.has_field_with_value("hours", "2.5h")

      time_logging_modal.update_time_field("start_time", hour: 12, minute: 0)

      time_logging_modal.has_field_with_value("end_time", "14:30")
      time_logging_modal.has_field_with_value("hours", "2.5h")
    end
  end
end
