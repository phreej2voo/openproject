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

module WorkPackages
  module Reminder
    class ModalBodyComponent < ApplicationComponent
      include ApplicationHelper
      include OpTurbo::Streamable
      include OpPrimer::ComponentHelpers

      FORM_ID = "reminder-form"

      attr_reader :remindable, :reminder, :errors

      def initialize(remindable:, reminder:, errors: nil)
        super

        @remindable = remindable
        @reminder = reminder
        @errors = errors
      end

      class << self
        def wrapper_key
          "reminder_modal_body"
        end
      end

      def submit_path
        if @reminder.persisted?
          work_package_reminder_path(@remindable, @reminder)
        else
          work_package_reminders_path(@remindable)
        end
      end

      def submit_button_text
        if @reminder.persisted?
          I18n.t(:button_save)
        else
          I18n.t(:button_set_reminder)
        end
      end

      def cancel_button_props
        {
          scheme: :secondary,
          data: {
            controller: "primer-to-angular-modal",
            application_target: "dynamic",
            action: "click->primer-to-angular-modal#close",
            test_selector: "op-reminder-modal-close-button"
          }
        }
      end

      def remind_at_date_initial_value
        format_time_as_date(@reminder.remind_at, format: "%Y-%m-%d")
      end

      def remind_at_time_initial_value
        format_time(@reminder.remind_at, include_date: false, format: "%H:%M")
      end
    end
  end
end
