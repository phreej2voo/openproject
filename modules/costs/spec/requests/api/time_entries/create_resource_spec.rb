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
require "rack/test"

RSpec.describe "API v3 Time Entries resource",
               content_type: :json,
               with_flag: :track_start_and_end_times_for_time_entries,
               with_settings: { allow_tracking_start_and_end_times: true } do
  include Rack::Test::Methods
  include API::V3::Utilities::PathHelper

  let(:project) { create(:project) }
  let(:active_activity) { create(:time_entry_activity) }
  let(:work_package) { create(:work_package, project:) }
  let(:permissions) { %i[log_time view_work_packages] }

  let(:german_user) do
    create(:user, member_with_permissions: { project => permissions }, preferences: { time_zone: "Europe/Berlin" })
  end
  let(:japanese_user) do
    create(:user, member_with_permissions: { project => [:view_project] }, preferences: { time_zone: "Asia/Tokyo" })
  end

  let(:path) { api_v3_paths.time_entries }
  let(:parameters) { {} }
  let(:json_response) { JSON.parse(response.body) }

  subject(:response) { last_response }

  describe "#POST /api/v3/time_entries" do
    before do
      login_as(german_user)
    end

    describe "correct time zone handling for start time" do
      context "when logging time for yourself" do
        let(:parameters) do
          {
            _links: {
              workPackage: { href: api_v3_paths.work_package(work_package.id) },
              project: { href: api_v3_paths.project(project.id) },
              activity: { href: api_v3_paths.time_entries_activity(active_activity.id) }
            },
            spentOn: "2024-12-24",
            hours: "PT2H",
            startTime: "2024-12-24T12:00:00Z"
          }
        end

        it "creates the time entry and sets the start time to the users timezone" do
          post path, parameters.to_json

          expect(subject).to have_http_status(:created)
          time_entry_id = json_response["id"]
          time_entry = TimeEntry.find(time_entry_id)

          expect(time_entry.spent_on).to eq(Date.new(2024, 12, 24))
          expect(time_entry.hours).to eq(2)
          expect(time_entry.start_time).to eq(13 * 60) # 12:00 UTC = 13:00 Berlin on December 24th, 2024
          expect(time_entry.time_zone).to eq("Europe/Berlin")
          expect(time_entry.user).to eq(german_user)
        end
      end

      context "when logging time for another user" do
        let(:parameters) do
          {
            _links: {
              user: { href: api_v3_paths.user(japanese_user.id) },
              workPackage: { href: api_v3_paths.work_package(work_package.id) },
              project: { href: api_v3_paths.project(project.id) },
              activity: { href: api_v3_paths.time_entries_activity(active_activity.id) }
            },
            spentOn: "2024-12-24",
            hours: "PT2H",
            startTime: "2024-12-24T12:00:00Z"
          }
        end

        it "creates the time entry and sets the start time to the users timezone" do
          post path, parameters.to_json

          expect(subject).to have_http_status(:created)
          time_entry_id = json_response["id"]
          time_entry = TimeEntry.find(time_entry_id)

          expect(time_entry.spent_on).to eq(Date.new(2024, 12, 24))
          expect(time_entry.hours).to eq(2)
          expect(time_entry.start_time).to eq(21 * 60) # 12:00 UTC = 21:00 Tokyo on Dec 24th, 2024
          expect(time_entry.time_zone).to eq("Asia/Tokyo")
          expect(time_entry.user).to eq(japanese_user)
        end
      end
    end
  end
end
