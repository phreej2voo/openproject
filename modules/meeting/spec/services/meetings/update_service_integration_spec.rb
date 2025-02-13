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

RSpec.describe Meetings::UpdateService, "integration", type: :model do
  include Redmine::I18n

  shared_let(:project) { create(:project, enabled_module_names: %i[meetings]) }
  shared_let(:user) do
    create(:user, member_with_permissions: { project => %i(view_meetings edit_meetings) })
  end

  let(:instance) { described_class.new(model: meeting, user:) }
  let(:attributes) { {} }
  let(:params) { {} }

  let(:service_result) { instance.call(attributes:, **params) }
  let(:updated_meeting) { service_result.result }

  context "when meeting is in a series and scheduled to the future" do
    let!(:recurring_meeting) { create(:recurring_meeting, project:, frequency: "daily") }
    let!(:meeting) { create(:structured_meeting, recurring_meeting:, project:, start_time: Time.zone.tomorrow + 10.hours) }
    let!(:schedule) do
      create(:scheduled_meeting,
             meeting:,
             start_time: Time.zone.today + 10.hours,
             recurring_meeting:)
    end

    context "when trying to move it to before the scheduled time" do
      let(:params) do
        { start_time: Time.zone.yesterday + 10.hours }
      end

      it "does not be valid" do
        expect(service_result).not_to be_success
        expect(service_result.errors[:start_date]).to include("must be after #{format_date(Time.zone.today + 10.hours)}.")
      end
    end
  end
end
