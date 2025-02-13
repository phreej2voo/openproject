# frozen_string_literal: true

# -- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2023 the OpenProject GmbH
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

module WorkPackages
  module ActivitiesTab
    class IndexComponent < ApplicationComponent
      include ApplicationHelper
      include OpPrimer::ComponentHelpers
      include OpTurbo::Streamable
      include WorkPackages::ActivitiesTab::SharedHelpers

      def initialize(work_package:, last_server_timestamp:, filter: :all, deferred: false)
        super

        @work_package = work_package
        @filter = filter
        @last_server_timestamp = last_server_timestamp
        @deferred = deferred
      end

      private

      attr_reader :work_package, :filter, :last_server_timestamp, :deferred

      def wrapper_data_attributes
        stimulus_controller = "work-packages--activities-tab--index"

        {
          test_selector: "op-wp-activity-tab",
          controller: stimulus_controller,
          "application-target": "dynamic",
          "#{stimulus_controller}-update-streams-path-value": update_streams_work_package_activities_path(work_package),
          "#{stimulus_controller}-sorting-value": journal_sorting,
          "#{stimulus_controller}-filter-value": filter,
          "#{stimulus_controller}-user-id-value": User.current.id,
          "#{stimulus_controller}-work-package-id-value": work_package.id,
          "#{stimulus_controller}-polling-interval-in-ms-value": polling_interval,
          "#{stimulus_controller}-notification-center-path-name-value": notifications_path,
          "#{stimulus_controller}-show-conflict-flash-message-url-value": show_conflict_flash_message_work_packages_path,
          "#{stimulus_controller}-last-server-timestamp-value": last_server_timestamp
        }
      end

      def polling_interval
        # Polling interval should only be adjustable in test environment
        if Rails.env.test?
          ENV["WORK_PACKAGES_ACTIVITIES_TAB_POLLING_INTERVAL_IN_MS"].presence || 10000
        else
          10000
        end
      end

      def adding_comment_allowed?
        User.current.allowed_in_work_package?(:add_work_package_notes, @work_package)
      end
    end
  end
end
