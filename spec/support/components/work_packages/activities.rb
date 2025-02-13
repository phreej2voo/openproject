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

module Components
  module WorkPackages
    class Activities
      include Capybara::DSL
      include Capybara::RSpecMatchers
      include RSpec::Matchers
      include RSpec::Wait

      attr_reader :work_package

      def initialize(work_package)
        @work_package = work_package
      end

      def expect_wp_has_been_created_activity(work_package)
        within "#work-package-activites-container" do
          created_date = work_package.created_at.strftime("%m/%d/%Y")
          expect(page).to have_text("created this on", wait: 10)
          expect(page).to have_text(created_date, wait: 10)
        end
      end

      def hover_action(journal_id, action)
        retry_block do
          # Focus type edit to expose buttons
          page
            .find("#activity-#{journal_id} .work-package-details-activities-activity-contents")
            .hover

          # Click the corresponding action button
          case action
          when :quote
            page.find("#activity-#{journal_id} .comments-icons .icon-quote").click
          end
        end
      end

      # helpers for new primerized activities

      def ckeditor
        Components::WysiwygEditor.new("#work-package-journal-form-element")
      end

      def get_editor_form_field_element
        FormFields::Primerized::EditorFormField.new("notes", selector: "#work-package-journal-form-element")
      end

      def journals_container_class_name
        "work-packages-activities-tab-journals-index-component"
      end

      def within_journals_container(&)
        page.within(".#{journals_container_class_name}", &)
      end

      def within_journal_entry(journal, &)
        wait_for { page }.to have_test_selector("op-wp-journal-entry-#{journal.id}") # avoid flakyness
        page.within_test_selector("op-wp-journal-entry-#{journal.id}", &)
      end

      def expect_journal_changed_attribute(text:)
        expect(page).to have_test_selector("op-journal-detail-description", text:, wait: 10)
      end

      def expect_no_journal_changed_attribute(text: nil)
        expect(page).not_to have_test_selector("op-journal-detail-description", text:, wait: 10)
      end

      def expect_no_journal_notes(text: nil)
        expect(page).not_to have_test_selector("op-journal-notes-body", text:, wait: 10)
      end

      def expect_journal_details_header(text: nil, count: nil)
        expect(page).to have_test_selector("op-journal-details-header", text:, count:, wait: 10)
      end

      def expect_no_journal_details_header(text: nil)
        expect(page).not_to have_test_selector("op-journal-details-header", text:, wait: 10)
      end

      def expect_journal_notes_header(text: nil)
        expect(page).to have_test_selector("op-journal-notes-header", text:, wait: 10)
      end

      def expect_no_journal_notes_header(text: nil)
        expect(page).not_to have_test_selector("op-journal-notes-header", text:, wait: 10)
      end

      def expect_journal_notes(text: nil, subselector: nil, count: nil)
        if text && subselector
          expect(page).to have_css("#{page.test_selector('op-journal-notes-body')} #{subselector}", text:, wait: 10)
        elsif text
          expect(page).to have_test_selector("op-journal-notes-body", text:, wait: 10)
        elsif count
          expect(page).to have_test_selector("op-journal-notes-body", count:, wait: 10)
        end
      end

      def expect_journal_mention(text: nil)
        expect_journal_notes # wait for the notes to be loaded

        expect(page).to have_css("a.user-mention", text:, wait: 10)
      end

      def expect_notification_bubble
        expect(page).to have_test_selector("op-journal-unread-notification", wait: 10)
      end

      def expect_no_notification_bubble
        expect(page).not_to have_test_selector("op-journal-unread-notification", wait: 10)
      end

      def expect_journal_container_at_bottom
        scroll_position = page.evaluate_script('document.querySelector(".tabcontent").scrollTop')
        scroll_height = page.evaluate_script('document.querySelector(".tabcontent").scrollHeight')
        client_height = page.evaluate_script('document.querySelector(".tabcontent").clientHeight')

        expect(scroll_position).to be_within(10).of(scroll_height - client_height)
      end

      def expect_journal_container_at_top
        scroll_position = page.evaluate_script('document.querySelector(".tabcontent").scrollTop')

        expect(scroll_position).to eq(0)
      end

      def expect_journal_container_at_position(position)
        scroll_position = page.evaluate_script('document.querySelector(".tabcontent").scrollTop')

        expect(scroll_position).to be_within(50).of(scroll_position - position)
      end

      def expect_empty_state
        expect(page).to have_test_selector("op-wp-journals-container-empty", wait: 10)
      end

      def expect_no_empty_state
        expect(page).not_to have_test_selector("op-wp-journals-container-empty", wait: 10)
      end

      def expect_input_field
        expect(page).to have_test_selector("op-work-package-journal-form", wait: 10)
      end

      def expect_no_input_field
        expect(page).not_to have_test_selector("op-work-package-journal-form", wait: 10)
      end

      def open_new_comment_editor
        page.find_test_selector("op-open-work-package-journal-form-trigger").click
      end

      def expect_focus_on_editor
        page.within_test_selector("op-work-package-journal-form-element") do
          expect(page).to have_css(".ck-content:focus")
        end
      end

      def expect_activity_anchor_link(text:)
        expect(page).to have_test_selector("activity-anchor-link", text:)
      end

      def expect_unsaved_content(text)
        page.within_test_selector("op-work-package-journal-form-element") do
          editor = get_editor_form_field_element
          expect(editor.input_element.value).to eq(text)
        end
      end

      def type_comment(text)
        open_new_comment_editor if page.find_test_selector("op-open-work-package-journal-form-trigger")

        # Wait for the editor form to be present and ready
        wait_for { page }.to have_test_selector("op-work-package-journal-form-element")

        page.within_test_selector("op-work-package-journal-form-element") do
          editor = get_editor_form_field_element
          # Wait for the editor to be initialized
          wait_for { editor.input_element }.to be_present
          editor.input_element.send_keys(text)
        end

        # Wait for any pending requests to complete
        wait_for_network_idle
      end

      def clear_comment(blur: false)
        page.within_test_selector("op-work-package-journal-form-element") do
          editor = get_editor_form_field_element
          editor.set_value("")

          if blur
            editor.input_element.send_keys(:tab) # triggers blur by moving focus away
          end
        end
      end

      def submit_comment
        page.find_test_selector("op-submit-work-package-journal-form").click
      end

      def add_comment(text: nil, save: true)
        if page.find_test_selector("op-open-work-package-journal-form-trigger")
          open_new_comment_editor
        else
          expect(page).to have_test_selector("op-work-package-journal-form-element")
        end

        page.within_test_selector("op-work-package-journal-form-element") do
          get_editor_form_field_element.set_value(text)
          page.find_test_selector("op-submit-work-package-journal-form").click if save
        end

        if save
          page.within_test_selector("op-wp-journals-container") do
            # wait for the comment to be loaded
            wait_for { page }.to have_test_selector("op-journal-notes-body", text:)
          end
        end

        wait_for_network_idle
      end

      def edit_comment(journal, text: nil, save: true)
        within_journal_entry(journal) do
          page.find_test_selector("op-wp-journal-#{journal.id}-action-menu").click
          page.find_test_selector("op-wp-journal-#{journal.id}-edit").click

          page.within_test_selector("op-work-package-journal-form-element") do
            get_editor_form_field_element.set_value(text)
            page.find_test_selector("op-submit-work-package-journal-form").click if save
          end

          if save
            # wait for the comment to be loaded
            wait_for { page }.to have_test_selector("op-journal-notes-body", text:)
          end
        end
      end

      def type_comment_in_edit(journal, text)
        within_journal_entry(journal) do
          page.find_test_selector("op-wp-journal-#{journal.id}-action-menu").click
          page.find_test_selector("op-wp-journal-#{journal.id}-edit").click

          page.within_test_selector("op-work-package-journal-form-element") do
            editor = get_editor_form_field_element
            # Wait for the editor to be initialized
            wait_for { editor.input_element }.to be_present
            editor.input_element.send_keys(text)
          end
        end
      end

      def quote_comment(journal)
        within_journal_entry(journal) do
          page.find_test_selector("op-wp-journal-#{journal.id}-action-menu").click
          page.find_test_selector("op-wp-journal-#{journal.id}-quote").click
        end

        expect(page).to have_test_selector("op-work-package-journal-form-element")

        page.within_test_selector("op-work-package-journal-form-element") do
          page.find_test_selector("op-submit-work-package-journal-form").click
        end
      end

      def get_all_comments_as_arrary
        page.all(".work-packages-activities-tab-journals-item-component--journal-notes-body").map(&:text)
      end

      def filter_journals(filter, default_sorting: User.current.preference&.comments_sorting || "desc")
        page.find_test_selector("op-wp-journals-filter-menu").click

        case filter
        when :all
          page.find_test_selector("op-wp-journals-filter-show-all").click
        when :only_comments
          page.find_test_selector("op-wp-journals-filter-show-only-comments").click
        when :only_changes
          page.find_test_selector("op-wp-journals-filter-show-only-changes").click
        end

        # Ensure the journals are reloaded
        # wait_for { page }.to have_test_selector("op-wp-journals-#{filter}-#{default_sorting}")
        # the wait_for will not work as the selector will be switched to the target filter before the page is updated
        # so we still need to wait statically unfortuntately to avoid flakyness
        sleep 1
      end

      def set_journal_sorting(sorting, default_filter: :all)
        page.find_test_selector("op-wp-journals-sorting-menu").click

        case sorting
        when :asc
          page.find_test_selector("op-wp-journals-sorting-asc").click
        when :desc
          page.find_test_selector("op-wp-journals-sorting-desc").click
        end

        wait_for { page }.to have_test_selector("op-wp-journals-#{default_filter}-#{sorting}")
      end
    end
  end
end
