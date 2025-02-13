# frozen_string_literal: true

# -- copyright
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
# ++

require "spec_helper"

RSpec.describe "Work package reminder modal",
               :js do
  let!(:project) { create(:project) }
  let!(:work_package) { create(:work_package, project:) }
  let!(:role_that_allows_managing_own_reminders) do
    create(:project_role, permissions: %i[view_work_packages])
  end
  let!(:role_that_does_not_allow_managing_own_reminders) do
    create(:project_role, permissions: %i[view_project])
  end

  let!(:user_with_permissions) do
    local_offset = Time.now.gmt_offset # rubocop:disable Rails/TimeZone
    time_zone = UserPreferences::UpdateContract.assignable_time_zones
                                                 .find { |tz| tz.now.utc_offset == local_offset }
    create(:user,
           member_with_roles: { project => role_that_allows_managing_own_reminders },
           preferences: { time_zone: time_zone.tzinfo.canonical_zone.name })
  end
  let!(:user_without_permissions) do
    create(:user,
           member_with_roles: { project => role_that_does_not_allow_managing_own_reminders })
  end

  let(:work_package_page) { Pages::FullWorkPackage.new(work_package) }
  let(:center) { Pages::Notifications::Center.new }

  context "with permissions to manage own reminders" do
    current_user { user_with_permissions }

    it "renders the reminder button when visiting the work package page" do
      work_package_page.visit!
      work_package_page.expect_reminder_button
    end

    specify "can create a reminder, subsequently update it and delete it" do
      date = Date.current + 2.weeks
      time = Time.zone.parse("05:00")

      work_package_page.visit!
      work_package_page.click_reminder_button
      wait_for_network_idle
      within ".spot-modal" do
        expect(page)
          .to have_css(".spot-modal--header-title", text: "Set reminder")
        expect(page)
          .to have_css(".spot-modal--subheader",
                       text: "You will receive a notification for this work package at the chosen time.")
        fill_in "Date", with: date
        fill_in "Time", with: time
        fill_in "Note", with: "Never forget!"

        click_link_or_button "Set reminder"
      end

      work_package_page.expect_and_dismiss_flash(type: :success,
                                                 message: I18n.t("work_package.reminders.success_creation_message"))
      work_package_page.expect_reminder_button_alarm_set_icon

      expect(Reminder.last)
      .to have_attributes(
        remindable: work_package,
        creator: user_with_permissions,
        remind_at: DateTime.parse("#{date} #{time}"),
        note: "Never forget!"
      )

      work_package_page.click_reminder_button
      wait_for_network_idle
      within ".spot-modal" do
        expect(page)
          .to have_css(".spot-modal--header-title", text: "Edit reminder")
        expect(page)
          .to have_css(".spot-modal--subheader",
                       text: "You will receive a notification for this work package at the chosen time.")
        expect(page).to have_field("Date", with: date)
        expect(page).to have_field("Time", with: time.in_time_zone(current_user.time_zone).strftime("%H:%M"))
        expect(page).to have_field("Note", with: "Never forget!")
        expect(page).to have_button("Save")

        fill_in "Note", with: "Remember to never forget!"
        click_link_or_button "Save"
      end

      work_package_page.expect_and_dismiss_flash(type: :success,
                                                 message: I18n.t("work_package.reminders.success_update_message"))
      expect(Reminder.last)
        .to have_attributes(
          remindable: work_package,
          creator: user_with_permissions,
          remind_at: DateTime.parse("#{date} #{time}"),
          note: "Remember to never forget!"
        )

      work_package_page.click_reminder_button
      wait_for_network_idle
      within ".spot-modal" do
        click_link_or_button "Remove reminder"
      end

      work_package_page.expect_and_dismiss_flash(type: :success,
                                                 message: I18n.t("work_package.reminders.success_deletion_message"))
      work_package_page.expect_reminder_button_alarm_not_set_icon
      expect(Reminder.upcoming_and_visible_to(user_with_permissions).count).to eq(0)
    end

    it "renders an error flash when the reminder modal is opened in edit mode" \
       "and the notification for it is fired and subsequently clicking save",
       with_settings: { notifications_polling_interval: 1_000 } do
      Reminders::CreateService.new(user: current_user).call(
        remindable: work_package,
        remind_at: 1.minute.from_now,
        creator: current_user,
        note: "Will fire soon"
      )

      work_package_page.visit!
      work_package_page.expect_reminder_button_alarm_set_icon
      work_package_page.click_reminder_button
      wait_for_network_idle

      within ".spot-modal" do
        expect(page)
          .to have_css(".spot-modal--header-title", text: "Edit reminder")
        expect(page)
          .to have_css(".spot-modal--subheader",
                       text: "You will receive a notification for this work package at the chosen time.")
      end

      perform_enqueued_jobs
      center.expect_bell_count(1)

      within ".spot-modal" do
        fill_in "Note", with: "I'm changing this"
        click_link_or_button "Save"
        wait_for_network_idle
      end

      work_package_page.expect_flash(type: :danger,
                                     message: I18n.t(:error_reminder_not_found))

      within ".spot-modal" do
        find_test_selector("op-reminder-dialog-modal--close-icon").click
      end

      work_package_page.dismiss_flash!
      work_package_page.expect_reminder_button_alarm_not_set_icon
      work_package_page.click_reminder_button
      wait_for_network_idle

      within ".spot-modal" do
        # Now it should be the create reminder modal
        expect(page).to have_css(".spot-modal--header-title", text: "Set reminder")
      end
    end

    describe "validations" do
      it "renders errors on the date field or time field when the reminder is in the past" do
        two_am = Time.zone.parse("02:00")
        thirty_minutes_ago = 30.minutes.ago
                                    .in_time_zone(current_user.time_zone)
                                    .strftime("%H:%M")
                                    .to_time
        thirty_minutes_from_now = 30.minutes.from_now
                                        .in_time_zone(current_user.time_zone)
                                        .strftime("%H:%M")
                                        .to_time
        yesterday = Time.current.in_time_zone(current_user.time_zone).yesterday.to_date
        today = Time.current.in_time_zone(current_user.time_zone).to_date

        work_package_page.visit!
        work_package_page.click_reminder_button
        wait_for_network_idle
        within ".spot-modal" do
          expect(page)
            .to have_css(".spot-modal--header-title", text: "Set reminder")
          expect(page)
            .to have_css(".spot-modal--subheader",
                         text: "You will receive a notification for this work package at the chosen time.")

          # Yesterday 02:00
          fill_in "Date", with: yesterday
          fill_in "Time", with: two_am
          fill_in "Note", with: "Never forget!"
          click_link_or_button "Set reminder"

          wait_for_network_idle
          expect(page).to have_css(".FormControl-inlineValidation", text: "Date must be in the future.")
          expect(page).to have_css(".FormControl-inlineValidation", text: "Time must be in the future.")

          # 30 minutes ago
          fill_in "Date", with: today
          fill_in "Time", with: thirty_minutes_ago
          click_link_or_button "Set reminder"

          wait_for_network_idle
          expect(page).to have_css(".FormControl-inlineValidation", text: "Time must be in the future.")
          expect(page).to have_no_css(".FormControl-inlineValidation", text: "Date must be in the future.", wait: 0)

          # 30 minutes from now
          fill_in "Date", with: today
          fill_in "Time", with: thirty_minutes_from_now
          click_link_or_button "Set reminder"

          wait_for_network_idle
        end

        work_package_page.expect_and_dismiss_flash(type: :success,
                                                   message: I18n.t("work_package.reminders.success_creation_message"))
        work_package_page.expect_reminder_button_alarm_set_icon
      end

      it "renders a required error on the date or time field when either isn't set" do
        work_package_page.visit!
        work_package_page.click_reminder_button
        wait_for_network_idle

        within ".spot-modal" do
          expect(page)
            .to have_css(".spot-modal--header-title", text: "Set reminder")
          expect(page)
            .to have_css(".spot-modal--subheader",
                         text: "You will receive a notification for this work package at the chosen time.")

          # Click the Schedule button without filling in the date or time
          click_link_or_button "Set reminder"

          wait_for_network_idle
          expect(page).to have_css(".FormControl-inlineValidation", text: "Date can't be blank")
          expect(page).to have_css(".FormControl-inlineValidation", text: "Time can't be blank")

          # Fill in the date but not the time
          fill_in "Date", with: 1.week.from_now.to_date
          click_link_or_button "Set reminder"

          wait_for_network_idle
          # The error message is only on the time field
          expect(page).to have_css(".FormControl-inlineValidation", text: "Time can't be blank")
          expect(page).to have_no_css(".FormControl-inlineValidation", text: "Date can't be blank", wait: 0)

          # Fill in the time but not the date
          fill_in "Date", with: ""
          fill_in "Time", with: Time.zone.parse("05:00")
          click_link_or_button "Set reminder"

          wait_for_network_idle
          expect(page).to have_css(".FormControl-inlineValidation", text: "Date can't be blank.")
          expect(page).to have_no_css(".FormControl-inlineValidation", text: "Time can't be blank.", wait: 0)
        end
      end

      it "removes the reminder count without a refresh when the notification is fired",
         with_settings: { notifications_polling_interval: 1_000 } do
        # Set to remind far in the future to avoid flakiness
        # and job triggered on demand later in the spec
        Reminders::CreateService.new(user: current_user).call(
          remindable: work_package,
          remind_at: 20.seconds.from_now,
          creator: current_user,
          note: "Just fired"
        )

        work_package_page.visit!
        work_package_page.expect_reminder_button_alarm_set_icon
        center.expect_bell_count(0)

        perform_enqueued_jobs

        center.expect_bell_count(1)
        work_package_page.expect_reminder_button_alarm_not_set_icon
      end
    end

    context "with a reminder" do
      let!(:reminder) do
        create(:reminder,
               remindable: work_package,
               creator: current_user)
      end

      it "renders the reminder button with the correct count" do
        work_package_page.visit!
        work_package_page.expect_reminder_button
        work_package_page.expect_reminder_button_alarm_set_icon
      end

      specify "clicking on the reminder button opens the edit reminder modal" do
        work_package_page.visit!
        work_package_page.click_reminder_button
        wait_for_network_idle
        within ".spot-modal" do
          expect(page)
            .to have_css(".spot-modal--header-title", text: "Edit reminder")
          expect(page)
            .to have_css(".spot-modal--subheader",
                         text: "You will receive a notification for this work package at the chosen time.")
          expect(page).to have_field("Date", with: reminder.remind_at.in_time_zone(current_user.time_zone).to_date)
          expect(page).to have_field("Time", with: reminder.remind_at.in_time_zone(current_user.time_zone).strftime("%H:%M"))
          expect(page).to have_field("Note", with: reminder.note)
          expect(page).to have_button("Save")
        end
      end
    end

    context "without a reminder" do
      it "renders the reminder button without a count" do
        work_package_page.visit!
        work_package_page.expect_reminder_button
        work_package_page.expect_reminder_button_alarm_not_set_icon
      end

      specify "clicking on the reminder button opens the create reminder modal" do
        work_package_page.visit!
        work_package_page.click_reminder_button
        wait_for_network_idle
        within ".spot-modal" do
          expect(page)
            .to have_css(".spot-modal--header-title", text: "Set reminder")
          expect(page)
            .to have_css(".spot-modal--subheader",
                         text: "You will receive a notification for this work package at the chosen time.")
          expect(page).to have_field("Date")
          expect(page).to have_field("Time")
          expect(page).to have_field("Note")
          expect(page).to have_button("Set reminder")
        end
      end
    end

    it "has a Primer close button that closes the Angular spot modal" do
      work_package_page.visit!
      work_package_page.click_reminder_button
      wait_for_network_idle
      within ".spot-modal" do
        expect(page)
          .to have_css(".spot-modal--header-title", text: "Set reminder")
        find_test_selector("op-reminder-modal-close-button").click
      end

      expect(page).to have_no_css(".spot-modal", wait: 0)
    end
  end

  context "without permissions to manage own reminders" do
    current_user { user_without_permissions }

    it "does not render the reminder button when visiting the work package page" do
      work_package_page.visit!
      work_package_page.expect_no_reminder_button
    end
  end

  context "with anonymous user with role that can view work packages", with_settings: { login_required: false } do
    before do
      ProjectRole.anonymous.add_permission! :view_work_packages
      project.update!(public: true)
    end

    current_user { User.anonymous }

    it "does not render the reminder button when visiting the work package page" do
      work_package_page.visit!
      work_package_page.ensure_loaded
      work_package_page.expect_no_reminder_button
    end
  end
end
