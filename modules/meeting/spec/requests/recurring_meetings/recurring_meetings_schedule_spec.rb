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

RSpec.describe "Recurring meetings schedule text",
               :skip_csrf,
               type: :rails_request do
  include Redmine::I18n

  shared_let(:project) { create(:project, enabled_module_names: %i[meetings]) }
  shared_let(:user) do
    create(:user,
           preferences: { time_zone: "Europe/London" },
           member_with_permissions: { project => %i[view_meetings create_meetings] })
  end
  let(:current_user) { user }

  let(:start_time_hour) { "10:00" }
  let(:start_date) { "2024-12-05" }
  let(:frequency) { "daily" }
  let(:interval) { "1" }
  let(:params) do
    { meeting: { start_time_hour:, start_date:, frequency:, interval: } }
  end
  let(:format) { :html }

  subject do
    get humanize_schedule_recurring_meetings_path(params:, format:)
    response
  end

  before do
    login_as(current_user)
  end

  describe "setting schedule" do
    it "returns the update text" do
      expect(subject).to have_http_status(:ok)
      expect(subject.body).to include("Daily at 10:00 AM")
    end

    context "when changing the frequency and interval" do
      let(:frequency) { "weekly" }
      let(:interval) { "2" }

      it "returns the update text" do
        expect(subject).to have_http_status(:ok)
        expect(subject.body).to include("Every 2 weeks on Thursday at 10:00 AM")
      end
    end

    context "when changing the interval" do
      let(:interval) { "2" }

      it "returns the update text" do
        expect(subject).to have_http_status(:ok)
        expect(subject.body).to include("Every 2 days at 10:00 AM")
      end
    end

    context "when leaving the interval empty" do
      let(:interval) { "" }

      it "falls back to the default" do
        expect(subject).to have_http_status(:ok)
        expect(subject.body).to include("Daily at 10:00 AM")
      end
    end

    context "when requesting with turbo" do
      let(:format) { :turbo_stream }

      it "returns an update turbo stream" do
        expect(subject).to have_http_status(:ok)
        expect(subject.body).to include("turbo-stream")
        expect(subject.body).to include("Daily at 10:00 AM")
      end
    end
  end

  context "when user has no permissions to access" do
    let(:current_user) { create(:user) }

    it "does not allow to request it" do
      expect(subject).to have_http_status(:forbidden)
    end
  end
end
