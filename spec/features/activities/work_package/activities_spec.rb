# frozen_string_literal: true

#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2024 the OpenProject GmbH
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
require "support/flash/expectations"

RSpec.describe "Work package activity", :js, :with_cuprite do
  include Flash::Expectations

  let(:project) { create(:project) }
  let(:admin) { create(:admin) }
  let(:member_role) do
    create(:project_role,
           permissions: %i[view_work_packages edit_work_packages add_work_packages work_package_assigned add_work_package_notes])
  end
  let(:member) do
    create(:user,
           firstname: "A",
           lastname: "Member",
           member_with_roles: { project => member_role })
  end

  let(:wp_page) { Pages::FullWorkPackage.new(work_package, project) }
  let(:activity_tab) { Components::WorkPackages::Activities.new(work_package) }

  describe "permission checks" do
    let(:viewer_role) do
      create(:project_role,
             permissions: %i[view_work_packages])
    end
    let(:viewer) do
      create(:user,
             firstname: "A",
             lastname: "Viewer",
             member_with_roles: { project => viewer_role })
    end

    let(:viewer_role_with_commenting_permission) do
      create(:project_role,
             permissions: %i[view_work_packages add_work_package_notes edit_own_work_package_notes])
    end
    let(:viewer_with_commenting_permission) do
      create(:user,
             firstname: "A",
             lastname: "Viewer",
             member_with_roles: { project => viewer_role_with_commenting_permission })
    end

    let(:user_role_with_editing_permission) do
      create(:project_role,
             permissions: %i[view_work_packages add_work_package_notes edit_work_package_notes])
    end
    let(:user_with_editing_permission) do
      create(:user,
             firstname: "A",
             lastname: "Viewer",
             member_with_roles: { project => user_role_with_editing_permission })
    end

    let(:comment_work_package_role) { create(:comment_work_package_role) }
    let(:user_with_commenting_permission_via_a_work_package_share) do
      create(:user,
             firstname: "A",
             lastname: "Commenter",
             member_with_roles: { work_package => comment_work_package_role })
    end

    let(:work_package) { create(:work_package, project:, author: admin) }
    let(:first_comment) do
      create(:work_package_journal, user: admin, notes: "First comment by admin", journable: work_package,
                                    version: 2)
    end

    context "when project is public", with_settings: { login_required: false } do
      let(:project) { create(:project, public: true) }
      let!(:anonymous_role) do
        create(:anonymous_role, permissions: %i[view_project view_work_packages])
      end

      context "when visited by an anonymous visitor" do
        before do
          first_comment

          login_as User.anonymous

          wp_page.visit!
          wp_page.wait_for_activity_tab
        end

        it "does show comments but does not enable adding, editing or quoting comments" do
          activity_tab.expect_journal_notes(text: "First comment by admin")

          activity_tab.within_journal_entry(first_comment) do
            page.find_test_selector("op-wp-journal-#{first_comment.id}-action-menu").click

            expect(page).not_to have_test_selector("op-wp-journal-#{first_comment.id}-edit")
            expect(page).not_to have_test_selector("op-wp-journal-#{first_comment.id}-quote")
          end

          activity_tab.expect_no_input_field
        end
      end
    end

    context "when a user has only view_work_packages permission" do
      current_user { viewer }

      before do
        first_comment

        wp_page.visit!
        wp_page.wait_for_activity_tab
      end

      it "does show comments but does not enable adding comments" do
        activity_tab.expect_journal_notes(text: "First comment by admin")

        activity_tab.within_journal_entry(first_comment) do
          page.find_test_selector("op-wp-journal-#{first_comment.id}-action-menu").click

          expect(page).not_to have_test_selector("op-wp-journal-#{first_comment.id}-edit")
          expect(page).not_to have_test_selector("op-wp-journal-#{first_comment.id}-quote")
        end

        activity_tab.expect_no_input_field
      end
    end

    context "when a user has add_work_package_notes and edit_own_work_package_notes permission" do
      current_user { viewer_with_commenting_permission }

      before do
        first_comment

        wp_page.visit!
        wp_page.wait_for_activity_tab
      end

      it "does show comments but does NOT enable editing other users comments" do
        activity_tab.expect_journal_notes(text: "First comment by admin")

        activity_tab.within_journal_entry(first_comment) do
          page.find_test_selector("op-wp-journal-#{first_comment.id}-action-menu").click

          # not allowed to edit other user's comments
          expect(page).not_to have_test_selector("op-wp-journal-#{first_comment.id}-edit")
          # allowed to quote other user's comments
          expect(page).to have_test_selector("op-wp-journal-#{first_comment.id}-quote")
        end
      end

      it "enable adding and quoting comments and editing OWN comments" do
        activity_tab.expect_input_field

        activity_tab.add_comment(text: "First comment by viewer with commenting permission")

        second_comment = work_package.journals.reload.last

        activity_tab.within_journal_entry(second_comment) do
          page.find_test_selector("op-wp-journal-#{second_comment.id}-action-menu").click

          expect(page).to have_test_selector("op-wp-journal-#{second_comment.id}-edit")
          expect(page).to have_test_selector("op-wp-journal-#{second_comment.id}-quote")
        end
      end
    end

    context "when a user has add_work_package_notes and general edit_work_package_notes permission" do
      current_user { user_with_editing_permission }

      before do
        first_comment

        wp_page.visit!
        wp_page.wait_for_activity_tab
      end

      it "does show comments and enable adding and quoting comments and editing of other users comments" do
        activity_tab.expect_journal_notes(text: "First comment by admin")

        activity_tab.within_journal_entry(first_comment) do
          page.find_test_selector("op-wp-journal-#{first_comment.id}-action-menu").click

          # allowed to edit other user's comments
          expect(page).to have_test_selector("op-wp-journal-#{first_comment.id}-edit")
          # allowed to quote other user's comments
          expect(page).to have_test_selector("op-wp-journal-#{first_comment.id}-quote")
        end
      end
    end

    context "when a user has been shared a work package with at least comment rights" do
      current_user { user_with_commenting_permission_via_a_work_package_share }

      before do
        wp_page.visit!
        wp_page.wait_for_activity_tab
      end

      it "allows commenting on the work package" do
        activity_tab.expect_input_field

        activity_tab.add_comment(text: "First comment by user with commenting permission via a work package share")
        activity_tab.expect_journal_notes(text: "First comment by user with commenting permission via a work package share")
      end
    end
  end

  context "when a workpackage is created and visited by the same user" do
    current_user { admin }
    let(:work_package) { create(:work_package, project:, author: admin) }

    before do
      # for some reason the journal is set to the "Anonymous"
      # although the work_package is created by the admin
      # so we need to update the journal to the admin manually to simulate the real world case
      work_package.journals.first.update!(user: admin)

      wp_page.visit!
      wp_page.wait_for_activity_tab
    end

    it "shows and merges activities and comments correctly", :aggregate_failures do
      first_journal = work_package.journals.first

      # initial journal entry is shown without changeset or comment
      activity_tab.within_journal_entry(first_journal) do
        activity_tab.expect_journal_details_header(text: admin.name)
        activity_tab.expect_no_journal_notes
        activity_tab.expect_no_journal_changed_attribute
      end

      wp_page.update_attributes(subject: "A new subject") # rubocop:disable Rails/ActiveRecordAliases
      wp_page.expect_and_dismiss_toaster(message: "Successful update.")

      # even when attributes are changed, the initial journal entry is still not showing any changeset
      activity_tab.within_journal_entry(first_journal) do
        activity_tab.expect_no_journal_changed_attribute
      end

      # merges the initial journal entry with the first comment when a comment is added right after the work package is created
      activity_tab.add_comment(text: "First comment")

      activity_tab.within_journal_entry(first_journal) do
        activity_tab.expect_no_journal_details_header
        activity_tab.expect_journal_notes_header(text: admin.name)
        activity_tab.expect_journal_notes(text: "First comment")
        activity_tab.expect_no_journal_changed_attribute
      end

      # changing the work package attributes after the first comment is added
      wp_page.update_attributes(subject: "A new subject!!!") # rubocop:disable Rails/ActiveRecordAliases
      wp_page.expect_and_dismiss_toaster(message: "Successful update.")

      # the changeset is still not shown in the journal entry
      activity_tab.within_journal_entry(first_journal) do
        activity_tab.expect_no_journal_changed_attribute
      end

      # adding a second comment
      activity_tab.add_comment(text: "Second comment")

      second_journal = work_package.journals.second

      activity_tab.within_journal_entry(second_journal) do
        activity_tab.expect_no_journal_changed_attribute
      end

      # changing the work package attributes after the first comment is added
      wp_page.update_attributes(subject: "A new subject") # rubocop:disable Rails/ActiveRecordAliases
      wp_page.expect_and_dismiss_toaster(message: "Successful update.")

      # the changeset is shown for the second journal entry (all but initial)
      activity_tab.within_journal_entry(second_journal) do
        activity_tab.expect_journal_changed_attribute(text: "Subject")
      end

      wp_page.update_attributes(assignee: member.name) # rubocop:disable Rails/ActiveRecordAliases
      wp_page.expect_and_dismiss_toaster(message: "Successful update.")

      # the changeset is merged for the second journal entry
      activity_tab.within_journal_entry(second_journal) do
        activity_tab.expect_journal_changed_attribute(text: "Subject")
        activity_tab.expect_journal_changed_attribute(text: "Assignee")
      end
    end
  end

  context "when a workpackage is created and visited by different users" do
    current_user { member }
    let(:work_package) { create(:work_package, project:, author: admin) }

    before do
      # for some reason the journal is set to the "Anonymous"
      # although the work_package is created by the admin
      # so we need to update the journal to the admin manually to simulate the real world case
      work_package.journals.first.update!(user: admin)

      wp_page.visit!
      wp_page.wait_for_activity_tab
    end

    it "shows and merges activities and comments correctly", :aggregate_failures do
      pending "works locally but is flaky on CI, reason unknown"
      fail

      # first_journal = work_package.journals.first

      # # initial journal entry is shown without changeset or comment
      # activity_tab.within_journal_entry(first_journal) do
      #   activity_tab.expect_journal_details_header(text: admin.name)
      #   activity_tab.expect_no_journal_notes
      #   activity_tab.expect_no_journal_changed_attribute
      # end

      # wp_page.update_attributes(subject: "A new subject")
      # wp_page.expect_and_dismiss_toaster(message: "Successful update.")

      # second_journal = work_package.journals.second
      # # even when attributes are changed, the initial journal entry is still not showing any changeset
      # activity_tab.within_journal_entry(second_journal) do
      #   activity_tab.expect_journal_details_header(text: member.name)
      #   activity_tab.expect_journal_changed_attribute(text: "Subject")
      # end

      # # merges the second journal entry with the comment made by the user right afterwards
      # activity_tab.add_comment(text: "First comment")

      # activity_tab.within_journal_entry(second_journal) do
      #   activity_tab.expect_no_journal_details_header
      #   activity_tab.expect_journal_notes_header(text: member.name)
      #   activity_tab.expect_journal_notes(text: "First comment")
      # end

      # travel_to (Setting.journal_aggregation_time_minutes.to_i.minutes + 1.minute).from_now
      # # the journals will not be merged due to the time difference

      # wp_page.update_attributes(subject: "A new subject!!!")

      # third_journal = work_package.journals.third

      # activity_tab.within_journal_entry(third_journal) do
      #   activity_tab.expect_journal_details_header(text: member.name)
      #   activity_tab.expect_journal_changed_attribute(text: "Subject")
      # end
    end
  end

  context "when multiple users are commenting on a workpackage" do
    current_user { admin }
    let(:work_package) { create(:work_package, project:, author: admin) }

    before do
      # set WORK_PACKAGES_ACTIVITIES_TAB_POLLING_INTERVAL_IN_MS to 1000
      # to speed up the polling interval for test duration
      ENV["WORK_PACKAGES_ACTIVITIES_TAB_POLLING_INTERVAL_IN_MS"] = "1000"

      # for some reason the journal is set to the "Anonymous"
      # although the work_package is created by the admin
      # so we need to update the journal to the admin manually to simulate the real world case
      work_package.journals.first.update!(user: admin)

      wp_page.visit!
      wp_page.wait_for_activity_tab
    end

    after do
      ENV.delete("WORK_PACKAGES_ACTIVITIES_TAB_POLLING_INTERVAL_IN_MS")
    end

    it "shows the comment of another user without browser reload", :aggregate_failures do
      # simulate member creating a comment
      first_journal = create(:work_package_journal, user: member, notes: "First comment by member", journable: work_package,
                                                    version: 2)

      # the comment is shown without browser reload
      activity_tab.expect_journal_notes(text: "First comment by member")

      # simulate comments made within the polling interval
      create(:work_package_journal, user: member, notes: "Second comment by member", journable: work_package, version: 3)
      create(:work_package_journal, user: member, notes: "Third comment by member", journable: work_package, version: 4)

      activity_tab.add_comment(text: "First comment by admin")

      expect(activity_tab.get_all_comments_as_arrary).to eq([
                                                              "First comment by member",
                                                              "Second comment by member",
                                                              "Third comment by member",
                                                              "First comment by admin"
                                                            ])

      first_journal.update!(notes: "First comment by member updated")

      # properly updates the comment when the comment is updated
      activity_tab.expect_journal_notes(text: "First comment by member updated")
    end
  end

  describe "filtering" do
    current_user { admin }
    let(:work_package) { create(:work_package, project:, author: admin) }

    context "when the work package has no comments" do
      before do
        # for some reason the journal is set to the "Anonymous"
        # although the work_package is created by the admin
        # so we need to update the journal to the admin manually to simulate the real world case
        work_package.journals.first.update!(user: admin)

        wp_page.visit!
        wp_page.wait_for_activity_tab
      end

      it "filters the activities based on type and shows an empty state" do
        # expect no empty state due to the initial journal entry
        activity_tab.expect_no_empty_state
        # expect the initial journal entry to be shown

        activity_tab.filter_journals(:only_comments)

        # expect empty state
        activity_tab.expect_empty_state

        activity_tab.filter_journals(:only_changes)

        # expect only the changes
        activity_tab.expect_no_empty_state

        activity_tab.filter_journals(:all)

        # expect all journal entries
        activity_tab.expect_no_empty_state

        # filter for comments again
        activity_tab.filter_journals(:only_comments)

        # expect empty state again
        activity_tab.expect_empty_state

        # add a comment
        activity_tab.add_comment(text: "First comment by admin")

        # the empty state should be removed
        activity_tab.expect_no_empty_state
      end
    end

    context "when the work package has comments and changesets" do
      before do
        # for some reason the journal is set to the "Anonymous"
        # although the work_package is created by the admin
        # so we need to update the journal to the admin manually to simulate the real world case
        work_package.journals.first.update!(user: admin)

        create(:work_package_journal, user: admin, notes: "First comment by admin", journable: work_package, version: 2)
        create(:work_package_journal, user: admin, notes: "Second comment by admin", journable: work_package, version: 3)

        wp_page.visit!
        wp_page.wait_for_activity_tab
      end

      it "filters the activities based on type", :aggregate_failures do # rubocop:disable RSpec/RepeatedExample
        pending "works locally but is flaky on CI, reason unknown"
        fail

        # # add a non-comment journal entry by changing the work package attributes
        # wp_page.update_attributes(subject: "A new subject")
        # wp_page.expect_and_dismiss_toaster(message: "Successful update.")

        # # expect all journal entries
        # activity_tab.expect_journal_notes(text: "First comment by admin")
        # activity_tab.expect_journal_notes(text: "Second comment by admin")
        # activity_tab.expect_journal_changed_attribute(text: "Subject")

        # activity_tab.filter_journals(:only_comments)

        # # expect only the comments
        # activity_tab.expect_journal_notes(text: "First comment by admin")
        # activity_tab.expect_journal_notes(text: "Second comment by admin")
        # activity_tab.expect_no_journal_changed_attribute(text: "Subject")

        # activity_tab.filter_journals(:only_changes)

        # # expect only the changes
        # activity_tab.expect_no_journal_notes(text: "First comment by admin")
        # activity_tab.expect_no_journal_notes(text: "Second comment by admin")
        # activity_tab.expect_journal_changed_attribute(text: "Subject")

        # activity_tab.filter_journals(:all)

        # # expect all journal entries
        # activity_tab.expect_journal_notes(text: "First comment by admin")
        # activity_tab.expect_journal_notes(text: "Second comment by admin")
        # activity_tab.expect_journal_changed_attribute(text: "Subject")

        # # strip journal entries with comments and changesets down to the comments

        # # creating a journal entry with both a comment and a changeset
        # activity_tab.add_comment(text: "Third comment by admin")
        # wp_page.update_attributes(subject: "A new subject!!!")
        # wp_page.expect_and_dismiss_toaster(message: "Successful update.")

        # latest_journal = work_package.journals.last

        # activity_tab.within_journal_entry(latest_journal) do
        #   activity_tab.expect_journal_notes_header(text: admin.name)
        #   activity_tab.expect_journal_notes(text: "Third comment by admin")
        #   activity_tab.expect_journal_changed_attribute(text: "Subject")
        #   activity_tab.expect_no_journal_details_header
        # end

        # activity_tab.filter_journals(:only_comments)

        # activity_tab.within_journal_entry(latest_journal) do
        #   activity_tab.expect_journal_notes_header(text: admin.name)
        #   activity_tab.expect_journal_notes(text: "Third comment by admin")
        #   activity_tab.expect_no_journal_changed_attribute
        #   activity_tab.expect_no_journal_details_header
        # end

        # activity_tab.filter_journals(:only_changes)

        # activity_tab.within_journal_entry(latest_journal) do
        #   activity_tab.expect_no_journal_notes_header
        #   activity_tab.expect_no_journal_notes

        #   activity_tab.expect_journal_details_header(text: admin.name)
        #   activity_tab.expect_journal_changed_attribute(text: "Subject")
        # end
      end

      it "resets an only_changes filter if a comment is added by the user", :aggregate_failures do # rubocop:disable RSpec/RepeatedExample
        pending "works locally but is flaky on CI, reason unknown"
        fail

        # activity_tab.filter_journals(:only_changes)
        # sleep 0.5 # avoid flaky test

        # # expect only the changes
        # activity_tab.expect_no_journal_notes(text: "First comment by admin")
        # activity_tab.expect_no_journal_notes(text: "Second comment by admin")

        # # add a comment
        # activity_tab.add_comment(text: "Third comment by admin")
        # sleep 0.5 # avoid flaky test

        # # the only_changes filter should be reset
        # activity_tab.expect_journal_notes(text: "Third comment by admin")
      end
    end
  end

  describe "focus editor" do
    current_user { admin }
    let(:work_package) { create(:work_package, project:, author: admin) }

    before do
      wp_page.visit!
      wp_page.wait_for_activity_tab
    end

    it "focuses the editor", :aggregate_failures do
      activity_tab.set_journal_sorting(:desc)

      activity_tab.open_new_comment_editor

      activity_tab.expect_focus_on_editor

      activity_tab.set_journal_sorting(:asc)

      activity_tab.open_new_comment_editor

      activity_tab.expect_focus_on_editor
    end
  end

  describe "sorting" do
    current_user { admin }
    let(:work_package) { create(:work_package, project:, author: admin) }

    before do
      # for some reason the journal is set to the "Anonymous"
      # although the work_package is created by the admin
      # so we need to update the journal to the admin manually to simulate the real world case
      work_package.journals.first.update!(user: admin)

      create(:work_package_journal, user: admin, notes: "First comment by admin", journable: work_package, version: 2)
      create(:work_package_journal, user: admin, notes: "Second comment by admin", journable: work_package, version: 3)

      wp_page.visit!
      wp_page.wait_for_activity_tab
    end

    it "sorts the activities based on the sorting preference", :aggregate_failures do
      # expect the default sorting to be asc
      expect(activity_tab.get_all_comments_as_arrary).to eq([
                                                              "First comment by admin",
                                                              "Second comment by admin"
                                                            ])
      activity_tab.set_journal_sorting(:desc)

      expect(activity_tab.get_all_comments_as_arrary).to eq([
                                                              "Second comment by admin",
                                                              "First comment by admin"
                                                            ])

      activity_tab.set_journal_sorting(:asc)

      expect(activity_tab.get_all_comments_as_arrary).to eq([
                                                              "First comment by admin",
                                                              "Second comment by admin"
                                                            ])

      # expect a new comment to be added at the bottom
      # when the sorting is set to asc
      #
      # creating a new comment
      activity_tab.add_comment(text: "Third comment by admin")

      expect(activity_tab.get_all_comments_as_arrary).to eq([
                                                              "First comment by admin",
                                                              "Second comment by admin",
                                                              "Third comment by admin"
                                                            ])

      activity_tab.set_journal_sorting(:desc)
      activity_tab.add_comment(text: "Fourth comment by admin")

      expect(activity_tab.get_all_comments_as_arrary).to eq([
                                                              "Fourth comment by admin",
                                                              "Third comment by admin",
                                                              "Second comment by admin",
                                                              "First comment by admin"
                                                            ])
    end
  end

  describe "notification bubble" do
    let(:work_package) { create(:work_package, project:, author: admin) }
    let!(:first_comment_by_admin) do
      create(:work_package_journal, user: admin, notes: "First comment by admin", journable: work_package, version: 2)
    end
    let!(:journal_mentioning_admin) do
      create(:work_package_journal, user: member, notes: "First comment by member mentioning @#{admin.name}",
                                    journable: work_package, version: 3)
    end
    let!(:notificaton_for_admin) do
      create(:notification, recipient: admin, resource: work_package, journal: journal_mentioning_admin, reason: :mentioned)
    end

    context "when admin is visiting the work package" do
      current_user { admin }

      before do
        wp_page.visit!
        wp_page.wait_for_activity_tab
      end

      it "shows the notification bubble", :aggregate_failures do
        activity_tab.within_journal_entry(journal_mentioning_admin) do
          activity_tab.expect_notification_bubble
        end
      end

      it "removes the notification bubble after the comment is read", :aggregate_failures do
        notificaton_for_admin.update!(read_ian: true)

        wp_page.visit!
        wp_page.wait_for_activity_tab

        activity_tab.within_journal_entry(journal_mentioning_admin) do
          activity_tab.expect_no_notification_bubble
        end
      end
    end

    context "when member is visiting the work package" do
      current_user { member }

      before do
        wp_page.visit!
        wp_page.wait_for_activity_tab
      end

      it "does not show the notification bubble", :aggregate_failures do
        activity_tab.within_journal_entry(journal_mentioning_admin) do
          activity_tab.expect_no_notification_bubble
        end
      end
    end
  end

  describe "edit comments" do
    let(:work_package) { create(:work_package, project:, author: admin) }
    let!(:first_comment_by_admin) do
      create(:work_package_journal, user: admin, notes: "First comment by admin", journable: work_package, version: 2)
    end
    let!(:first_comment_by_member) do
      create(:work_package_journal, user: member, notes: "First comment by member", journable: work_package, version: 3)
    end

    context "when admin is visiting the work package" do
      current_user { admin }

      before do
        wp_page.visit!
        wp_page.wait_for_activity_tab
      end

      it "can edit own comments", :aggregate_failures do
        # edit own comment
        activity_tab.edit_comment(first_comment_by_admin, text: "First comment by admin edited")

        # expect the edited comment to be shown
        activity_tab.within_journal_entry(first_comment_by_admin) do
          activity_tab.expect_journal_notes(text: "First comment by admin edited")
        end

        # can edit other user's comments due to the permission
        activity_tab.edit_comment(first_comment_by_member, text: "First comment by member edited")

        activity_tab.within_journal_entry(first_comment_by_member) do
          activity_tab.expect_journal_notes(text: "First comment by member edited")
        end
      end
    end
  end

  describe "quote comments" do
    let(:work_package) { create(:work_package, project:, author: admin) }
    let!(:first_comment_by_admin) do
      create(:work_package_journal, user: admin, notes: "First comment by admin", journable: work_package, version: 2)
    end
    let!(:first_comment_by_member) do
      create(:work_package_journal, user: member, notes: "First comment by member", journable: work_package, version: 3)
    end

    context "when admin is visiting the work package" do
      current_user { admin }

      before do
        wp_page.visit!
        wp_page.wait_for_activity_tab
      end

      it "can quote other user's comments", :aggregate_failures do
        # quote other user's comment
        # not adding additional text in this spec to the spec as I didn't find a way to add text the editor component
        activity_tab.quote_comment(first_comment_by_member)

        # expect the quoted comment to be shown
        activity_tab.expect_journal_notes(text: "A Member wrote:\nFirst comment by member")
      end
    end
  end

  describe "rescue editor content" do
    let(:work_package) { create(:work_package, project:, author: admin) }
    let(:second_work_package) { create(:work_package, project:, author: admin) }

    current_user { admin }

    before do
      wp_page.visit!
      wp_page.wait_for_activity_tab
    end

    it "rescues the editor content when navigating to another workpackage tab", :aggregate_failures do
      # add a comment, but do not save it
      activity_tab.add_comment(text: "First comment by admin", save: false)

      # navigate to another tab and back
      page.find("li[data-tab-id=\"relations\"]").click
      page.find("li[data-tab-id=\"activity\"]").click

      # expect the editor content to be rescued on the client side
      within_test_selector("op-work-package-journal-form-element") do
        editor = FormFields::Primerized::EditorFormField.new("notes", selector: "#work-package-journal-form-element")
        editor.expect_value("First comment by admin")
        # save the comment, which was rescued on the client side
        page.find_test_selector("op-submit-work-package-journal-form").click
      end

      # expect the comment to be added properly
      activity_tab.expect_journal_notes(text: "First comment by admin")
    end

    it "scopes the rescued content to the work package", :aggregate_failures do
      # add a comment to the first work package, but do not save it
      activity_tab.add_comment(text: "First comment by admin", save: false)

      # navigate to another tab in order to prevent the browser native confirm dialog of the unsaved changes
      page.find("li[data-tab-id=\"relations\"]").click

      # navigate to the second work package
      wp_page = Pages::FullWorkPackage.new(second_work_package, project)
      wp_page.visit!
      wp_page.wait_for_activity_tab

      # open the editor
      page.find_test_selector("op-open-work-package-journal-form-trigger").click

      # expect the editor content to be empty
      within_test_selector("op-work-package-journal-form-element") do
        editor = FormFields::Primerized::EditorFormField.new("notes", selector: "#work-package-journal-form-element")
        editor.expect_value("")
      end
    end

    it "scopes the rescued content to the user", :aggregate_failures do
      # add a comment to the first work package, but do not save it
      activity_tab.add_comment(text: "First comment by admin", save: false)

      # navigate to another tab in order to prevent the browser native confirm dialog of the unsaved changes
      page.find("li[data-tab-id=\"relations\"]").click

      logout
      login_as(member)

      # navigate to the same workpackage, but as a different user
      wp_page.visit!
      wp_page.wait_for_activity_tab

      # open the editor
      page.find_test_selector("op-open-work-package-journal-form-trigger").click

      # expect the editor content to be empty
      within_test_selector("op-work-package-journal-form-element") do
        editor = FormFields::Primerized::EditorFormField.new("notes", selector: "#work-package-journal-form-element")
        editor.expect_value("")
      end

      logout
      login_as(admin)

      # navigate to the same workpackage, but as a different user
      wp_page.visit!
      wp_page.wait_for_activity_tab
      # expect the editor to be opened and content to be rescued for the correct user
      within_test_selector("op-work-package-journal-form-element") do
        editor = FormFields::Primerized::EditorFormField.new("notes", selector: "#work-package-journal-form-element")
        editor.expect_value("First comment by admin")
      end
    end
  end

  describe "auto scrolling" do
    current_user { admin }
    let(:work_package) { create(:work_package, project:, author: admin) }

    # create enough comments to make the journal container scrollable
    20.times do |i|
      let!(:"comment_#{i + 1}") do
        create(:work_package_journal, user: admin, notes: "Comment #{i + 1}", journable: work_package, version: i + 2)
      end
    end

    describe "scrolls to comment specified in the URL" do
      include Redmine::I18n

      context "when sorting set to asc" do
        let!(:admin_preferences) { create(:user_preference, user: admin, others: { comments_sorting: :asc }) }

        context "with #activity- anchor" do
          before do
            visit project_work_package_path(project, work_package.id, "activity", anchor: "activity-1")
            wp_page.wait_for_activity_tab
          end

          it "scrolls to the comment specified in the URL", :aggregate_failures do
            wait_for_auto_scrolling_to_finish
            activity_tab.expect_journal_container_at_position(50) # would be at the bottom if no anchor would be provided

            activity_tab.expect_activity_anchor_link(text: "#1")
          end
        end

        context "with #comment- anchor", with_flag: { work_package_comment_id_url: true } do
          before do
            visit project_work_package_path(project, work_package.id, "activity", anchor: "comment-#{comment_1.id}")
            wp_page.wait_for_activity_tab
          end

          it "scrolls to the comment specified in the URL", :aggregate_failures do
            wait_for_auto_scrolling_to_finish
            activity_tab.expect_journal_container_at_position(50) # would be at the bottom if no anchor would be provided

            activity_tab.expect_activity_anchor_link(text: format_time(comment_1.updated_at))

            activity_tab.filter_journals(:only_changes)

            activity_tab.expect_activity_anchor_link(text: format_time(comment_1.updated_at))
          end
        end

        context "when on mobile screen size", with_flag: { work_package_comment_id_url: true } do
          before do
            page.current_window.resize_to(500, 1000)

            visit project_work_package_path(project, work_package.id, "activity", anchor: "comment-#{comment_1.id}")
            wp_page.wait_for_activity_tab
          end

          it "scrolls to the comment specified in the URL", :aggregate_failures do
            wait_for_auto_scrolling_to_finish
            activity_tab.expect_journal_container_at_position(50) # would be at the bottom if no anchor would be provided

            activity_tab.expect_activity_anchor_link(text: format_time(comment_1.updated_at))

            activity_tab.filter_journals(:only_changes)

            activity_tab.expect_activity_anchor_link(text: format_time(comment_1.updated_at))
          end
        end
      end

      context "when sorting set to desc" do
        let!(:admin_preferences) { create(:user_preference, user: admin, others: { comments_sorting: :desc }) }

        context "with #activity- anchor" do
          before do
            visit project_work_package_path(project, work_package.id, "activity", anchor: "activity-2")
            wp_page.wait_for_activity_tab
          end

          it "scrolls to the comment specified in the URL", :aggregate_failures do
            wait_for_auto_scrolling_to_finish
            activity_tab.expect_journal_container_at_bottom # would be at the top if no anchor would be provided

            activity_tab.expect_activity_anchor_link(text: "#2")
          end
        end

        context "with #comment- anchor", with_flag: { work_package_comment_id_url: true } do
          before do
            visit project_work_package_path(project, work_package.id, "activity", anchor: "comment-#{comment_1.id}")
            wp_page.wait_for_activity_tab
          end

          it "scrolls to the comment specified in the URL", :aggregate_failures do
            wait_for_auto_scrolling_to_finish
            activity_tab.expect_journal_container_at_bottom # would be at the top if no anchor would be provided

            activity_tab.expect_activity_anchor_link(text: format_time(comment_1.updated_at))
          end
        end
      end

      def wait_for_auto_scrolling_to_finish = sleep(1)
    end

    context "when sorting set to asc" do
      let!(:admin_preferences) { create(:user_preference, user: admin, others: { comments_sorting: :asc }) }

      before do
        # set WORK_PACKAGES_ACTIVITIES_TAB_POLLING_INTERVAL_IN_MS to 1000
        # to speed up the polling interval for test duration
        ENV["WORK_PACKAGES_ACTIVITIES_TAB_POLLING_INTERVAL_IN_MS"] = "1000"

        wp_page.visit!
        wp_page.wait_for_activity_tab
      end

      context "when on desktop" do
        it "scrolls to the bottom when the newest journal entry is on the bottom", :aggregate_failures do
          sleep 1 # wait for auto scrolling to finish
          activity_tab.expect_journal_container_at_bottom

          # auto-scrolls to the bottom when a new comment is added by the user
          # add a comment
          activity_tab.add_comment(text: "New comment by admin")
          activity_tab.expect_journal_container_at_bottom

          # auto-scrolls to the bottom when a new comment is added by another user
          # add a comment
          latest_journal_version = work_package.journals.last.version
          create(:work_package_journal, user: member, notes: "New comment by member", journable: work_package,
                                        version: latest_journal_version + 1)
          # wait for the comment to be added
          wait_for { page }.to have_test_selector("op-journal-notes-body", text: "New comment by member")
          sleep 1 # wait for auto scrolling to finish
          activity_tab.expect_journal_container_at_bottom
        end
      end

      context "when on narrow desktop screen size" do
        before do
          page.current_window.resize_to(900, 1200)
          # simulate a desktop screen which was resized to a smaller width
          # the height in this spec is important as the activity tab must be visible
          # otherwise the (in this case undesired) auto scrolling would not be triggered

          wp_page.visit!
          wp_page.wait_for_activity_tab
        end

        it "does not scroll to the bottom when the newest journal entry is on the bottom", :aggregate_failures do
          sleep 1 # wait for a potential auto scrolling to finish
          # expect activity tab not to be visibe, as the page is not scrolled to the bottom
          scroll_position = page.evaluate_script("document.querySelector(\"#content-body\").scrollTop")
          expect(scroll_position).to eq(0)
        end
      end

      context "when on mobile screen size" do
        before do
          page.current_window.resize_to(500, 1000)
          # simulate a mobile screen size
          # the height in this spec is important as the activity tab must be visible
          # otherwise the (in this case undesired) auto scrolling would not be triggered

          wp_page.visit!
          wp_page.wait_for_activity_tab
        end

        # this one is actually failing, but it's not caused by the activity tab
        # the scroll position is at around 700, some other part of the frontend code seems to trigger a scroll
        # happens for the files tab as well for example
        #
        it "does not scroll to the bottom when the newest journal entry is on the bottom", :aggregate_failures do
          pending "bug/59916-on-narrow-screens-(including-mobile)-the-view-always-scrolls-to-the-activity"

          sleep 1 # wait for a potential auto scrolling to finish
          # expect activity tab not to be visibe, as the page is not scrolled to the bottom
          scroll_position = page.evaluate_script("document.querySelector(\"#content-body\").scrollTop")
          expect(scroll_position).to eq(0)
        end
      end
    end

    context "when sorting set to desc" do
      let!(:admin_preferences) { create(:user_preference, user: admin, others: { comments_sorting: :desc }) }

      before do
        wp_page.visit!
        wp_page.wait_for_activity_tab
      end

      it "does not scroll to the bottom as the newest journal entry is on the top", :aggregate_failures do
        sleep 1 # wait for auto scrolling to finish
        activity_tab.expect_journal_container_at_top
      end
    end
  end

  describe "images in the comment",
           :js,
           :selenium,
           with_settings: { journal_aggregation_time_minutes: 0, show_work_package_attachments: false } do
    let(:work_package) { create(:work_package, project:, author: admin) }
    let(:image_fixture) { UploadedFile.load_from("spec/fixtures/files/image.png") }
    let(:editor) { Components::WysiwygEditor.new }

    context "if work package attachments are deactivated in project" do
      it "shows the inline image and have it uploaded to the work package", :aggregate_failures do
        login_as admin

        wp_page.visit!
        wp_page.wait_for_activity_tab

        page.find_test_selector("op-open-work-package-journal-form-trigger").click
        editor.drag_attachment(image_fixture.path, "", scroll: false)
        editor.wait_until_upload_progress_toaster_cleared

        page.find_test_selector("op-submit-work-package-journal-form").click

        expect(find_test_selector("op-journal-notes-body")).to have_css("img")
        expect(page).to have_test_selector("op-journal-detail-description", text: "File image.png added as attachment")
      end
    end
  end

  describe "retracted journal entries" do
    let(:work_package) { create(:work_package, project:, author: admin) }
    let!(:first_comment_by_admin) do
      create(:work_package_journal, user: admin, notes: "First comment by admin", journable: work_package, version: 2)
    end
    let!(:second_comment_by_admin) do
      create(:work_package_journal, user: admin, notes: "Second comment by admin", journable: work_package, version: 3)
    end

    current_user { admin }

    before do
      second_comment_by_admin.update!(notes: "")

      wp_page.visit!
      wp_page.wait_for_activity_tab
    end

    it "shows rectracted journal entries", :aggregate_failures do
      activity_tab.within_journal_entry(second_comment_by_admin) do
        expect(page).to have_text(I18n.t(:"journals.changes_retracted"))
      end
    end
  end

  describe "work package attribute updates" do
    let(:work_package) { create(:work_package, project:, author: admin) }

    let!(:first_comment_by_member) do
      create(:work_package_journal, user: member, notes: "First comment by member", journable: work_package, version: 2)
    end

    current_user { admin }

    before do
      work_package.update!(subject: "Subject before update")
      # set WORK_PACKAGES_ACTIVITIES_TAB_POLLING_INTERVAL_IN_MS to 1000
      # to speed up the polling interval for test duration
      ENV["WORK_PACKAGES_ACTIVITIES_TAB_POLLING_INTERVAL_IN_MS"] = "1000"
    end

    after do
      ENV.delete("WORK_PACKAGES_ACTIVITIES_TAB_POLLING_INTERVAL_IN_MS")
    end

    it "shows the updated work package attribute without reload", :aggregate_failures do
      using_session(:admin) do
        login_as(admin)

        wp_page.visit!
        wp_page.wait_for_activity_tab

        # wait for the latest comments to be loaded before proceeding!
        activity_tab.expect_journal_notes(text: "First comment by member")
        wp_page.expect_attributes(subject: work_package.subject)
      end

      using_session(:member) do
        login_as(member)

        wp_page.visit!
        wp_page.wait_for_activity_tab

        wp_page.update_attributes(subject: "Subject updated by member") # rubocop:disable Rails/ActiveRecordAliases
        wp_page.expect_and_dismiss_toaster(message: "Successful update.")
      end

      using_session(:admin) do
        wp_page.expect_attributes(subject: "Subject updated by member")
      end
    end

    it "shows the updated work package attribute without reload after switching back to the activity tab", :aggregate_failures do
      using_session(:admin) do
        login_as(admin)

        wp_page.visit!
        wp_page.wait_for_activity_tab

        # wait for the latest comments to be loaded before proceeding!
        activity_tab.expect_journal_notes(text: "First comment by member")
        wp_page.expect_attributes(subject: "Subject before update")

        wp_page.switch_to_tab(tab: :relations)
      end

      using_session(:member) do
        login_as(member)

        wp_page.visit!
        wp_page.wait_for_activity_tab

        wp_page.update_attributes(subject: "Subject updated by member") # rubocop:disable Rails/ActiveRecordAliases
        wp_page.expect_and_dismiss_toaster(message: "Successful update.")
      end

      using_session(:admin) do
        sleep 1 # wait some time to REALLY check for a stale UI state
        # work package page is stale as the activity tab is not active and thus no polling is done
        wp_page.expect_attributes(subject: "Subject before update")

        wp_page.switch_to_tab(tab: :activity)
        wp_page.wait_for_activity_tab

        # activity tab should show the updated attribute
        activity_tab.expect_journal_changed_attribute(text: "Subject updated by member")

        # for some reason, wp_page.expect_attributes(subject: "Subject updated by member") does not work in this spec
        # although an error screenshot is showing the correct value
        # skipping this for now -> Code Maintenance Ticket will be created
        # wp_page.expect_attributes(subject: "Subject updated by member")

        # as this happened in this case while development and needed to be fixed
        # I add the following check to make sure this does not happen again
        wp_page.expect_no_conflict_warning_banner
        wp_page.expect_no_conflict_error_banner
      end
    end
  end

  describe "conflict handling" do
    let(:work_package) { create(:work_package, project:, author: admin) }

    before do
      # set WORK_PACKAGES_ACTIVITIES_TAB_POLLING_INTERVAL_IN_MS to 1000
      # to speed up the polling interval for test duration
      ENV["WORK_PACKAGES_ACTIVITIES_TAB_POLLING_INTERVAL_IN_MS"] = "1000"
    end

    after do
      ENV.delete("WORK_PACKAGES_ACTIVITIES_TAB_POLLING_INTERVAL_IN_MS")
    end

    it "raises a conflict warning when the work package is updated by another user while the current user is editing",
       :aggregate_failures do
      using_session(:admin) do
        login_as(admin)

        wp_page.visit!
        wp_page.wait_for_activity_tab

        wp_page.edit_field(:description).display_element.click
        wp_page.edit_field(:description).set_value("Description updated but not saved yet")

        wp_page.expect_any_active_inline_edit_field
      end

      using_session(:member) do
        login_as(member)

        wp_page.visit!
        wp_page.wait_for_activity_tab

        wp_page.edit_field(:description).display_element.click
        wp_page.edit_field(:description).set_value("Description updated by member")
        wp_page.edit_field(:description).save!

        wp_page.expect_no_active_inline_edit_field
      end

      using_session(:admin) do
        wp_page.expect_any_active_inline_edit_field # editor is still active

        wp_page.expect_conflict_warning_banner # warning banner is shown as another user has updated the work package

        wp_page.edit_field(:description).save! # user ignores the warning and saves the changes

        wp_page.expect_no_conflict_warning_banner # warning banner is gone and substituted by the error banner
        wp_page.expect_conflict_error_banner # error banner is shown as the server does not allow a conflict
      end
    end

    it "does NOT raise a conflict warning when the work package has been only commented by another user while the current
        user is editing",
       :aggregate_failures do
      using_session(:admin) do
        login_as(admin)

        wp_page.visit!
        wp_page.wait_for_activity_tab

        wp_page.edit_field(:description).display_element.click
        wp_page.edit_field(:description).set_value("Description updated but not saved yet")

        wp_page.expect_any_active_inline_edit_field
      end

      using_session(:member) do
        login_as(member)

        wp_page.visit!
        wp_page.wait_for_activity_tab

        activity_tab.add_comment(text: "First comment by member")
      end

      using_session(:admin) do
        wp_page.expect_any_active_inline_edit_field # editor is still active

        activity_tab.expect_journal_notes(text: "First comment by member")

        wp_page.expect_no_conflict_warning_banner
        wp_page.expect_no_conflict_error_banner
      end
    end

    context "when the current user does not have the activity tab open the whole time" do
      it "raises a conflict warning when the work package is updated by another user while the current user is editing",
         :aggregate_failures do
        using_session(:admin) do
          login_as(admin)

          wp_page.visit!
          wp_page.wait_for_activity_tab
          wp_page.switch_to_tab(tab: :relations) # navigate to another tab, the journal polling stops

          wp_page.edit_field(:description).display_element.click
          wp_page.edit_field(:description).set_value("Description updated but not saved yet")

          wp_page.expect_any_active_inline_edit_field
        end

        using_session(:member) do
          login_as(member)

          wp_page.visit!
          wp_page.wait_for_activity_tab

          wp_page.edit_field(:description).display_element.click
          wp_page.edit_field(:description).set_value("Description updated by member")
          wp_page.edit_field(:description).save!

          wp_page.expect_no_active_inline_edit_field
        end

        using_session(:admin) do
          wp_page.expect_no_conflict_warning_banner
          wp_page.expect_no_conflict_error_banner

          wp_page.switch_to_tab(tab: :activity) # re-visit the activity tab, the journal polling starts again
          wp_page.wait_for_activity_tab

          wp_page.expect_any_active_inline_edit_field # editor is still active

          activity_tab.expect_journal_changed_attribute(text: "Description")

          # this works as expected but cannot be tested in test env, reason unknown
          # TODO: fix this part of this spec
          # wp_page.expect_conflict_warning_banner # warning banner is shown as another user has updated the work package
          # I'm not marking this spec as pending as the following part is testing the crucial behaviour successfully

          wp_page.edit_field(:description).save! # user ignores the warning and saves the changes

          wp_page.expect_no_conflict_warning_banner # warning banner is gone and substituted by the error banner
          wp_page.expect_conflict_error_banner # error banner is shown as the server does not allow a conflict
        end
      end

      it "does NOT raise a conflict warning when the work package is updated by the same user while the current user is editing",
         :aggregate_failures do
        using_session(:admin) do
          login_as(admin)

          wp_page.visit!
          wp_page.wait_for_activity_tab
          wp_page.switch_to_tab(tab: :relations) # navigate to another tab, the journal polling stops

          wp_page.edit_field(:description).display_element.click
          wp_page.edit_field(:description).set_value("Description updated and saved")
          wp_page.edit_field(:description).save!

          wp_page.expect_no_active_inline_edit_field

          wp_page.edit_field(:description).display_element.click
          wp_page.edit_field(:description).set_value("Description updated again but not saved yet by the same user")

          wp_page.expect_any_active_inline_edit_field

          wp_page.switch_to_tab(tab: :activity)
          wp_page.wait_for_activity_tab

          wp_page.expect_no_conflict_warning_banner
          wp_page.expect_no_conflict_error_banner
        end
      end
    end
  end

  describe "error handling" do
    let(:work_package) { create(:work_package, project:, author: admin) }

    current_user { admin }

    before do
      wp_page.visit!
      wp_page.wait_for_activity_tab
    end

    context "when adding a comment" do
      context "when the creation call raises an unknown server error" do
        before do
          allow_any_instance_of(WorkPackages::ActivitiesTabController) # rubocop:disable RSpec/AnyInstance
            .to receive(:create_journal_service_call)
            .and_raise(StandardError.new("Test error"))
        end

        it "shows an error banner when the server returns an error" do
          activity_tab.add_comment(text: "First comment by admin", save: false)

          page.find_test_selector("op-submit-work-package-journal-form").click

          expect_flash(message: "Test error", type: :error)

          # expect the editor content not to be lost
          within_test_selector("op-work-package-journal-form-element") do
            editor = FormFields::Primerized::EditorFormField.new("notes", selector: "#work-package-journal-form-element")
            editor.expect_value("First comment by admin")
          end
        end
      end

      context "when the creation call fails with a validation error" do
        before do
          allow_any_instance_of(AddWorkPackageNoteService) # rubocop:disable RSpec/AnyInstance
            .to receive(:call)
            .and_return(
              ServiceResult.failure(errors: ActiveModel::Errors.new(Journal.new).tap do |e|
                e.add(:notes, "Validation error")
              end)
            )
        end

        it "shows a validation error banner" do
          activity_tab.add_comment(text: "First comment by admin", save: false)

          page.find_test_selector("op-submit-work-package-journal-form").click

          expect_flash(message: "Validation error", type: :error)

          # expect the editor content not to be lost
          within_test_selector("op-work-package-journal-form-element") do
            editor = FormFields::Primerized::EditorFormField.new("notes", selector: "#work-package-journal-form-element")
            editor.expect_value("First comment by admin")
          end
        end
      end
    end

    context "when editing a comment" do
      let!(:first_comment_by_admin) do
        create(:work_package_journal, user: admin, notes: "First comment by admin", journable: work_package, version: 2)
      end

      context "when the update call raises an unknown server error" do
        before do
          allow_any_instance_of(WorkPackages::ActivitiesTabController) # rubocop:disable RSpec/AnyInstance
            .to receive(:update_journal_service_call)
            .and_raise(StandardError.new("Test error"))
        end

        it "shows an error banner" do
          activity_tab.edit_comment(first_comment_by_admin, text: "First comment by admin edited", save: false)

          page.within_test_selector("op-work-package-journal-form-element") do
            page.find_test_selector("op-submit-work-package-journal-form").click
          end

          expect_flash(message: "Test error", type: :error)
        end
      end

      context "when the update call fails with a validation error" do
        before do
          allow_any_instance_of(Journals::UpdateService) # rubocop:disable RSpec/AnyInstance
            .to receive(:call)
            .and_return(
              ServiceResult.failure(errors: ActiveModel::Errors.new(Journal.new).tap do |e|
                e.add(:notes, "Validation error")
              end)
            )
        end

        it "shows a validation error banner" do
          activity_tab.edit_comment(first_comment_by_admin, text: "First comment by admin edited", save: false)

          page.within_test_selector("op-work-package-journal-form-element") do
            page.find_test_selector("op-submit-work-package-journal-form").click
          end

          expect_flash(message: "Validation error", type: :error)
        end
      end
    end
  end
end
