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

RSpec.describe API::V3::Reminders::RemindersAPI do
  let!(:project) { create(:project) }

  let!(:role_with_permissions) { create(:project_role, permissions: %i[view_work_packages]) }
  let!(:role_without_permissions) { create(:project_role, permissions: %i[view_project]) }

  let!(:user_with_permissions) do
    create(:user, member_with_roles: { project => role_with_permissions })
  end
  let!(:other_user_without_permissions) do
    create(:user, member_with_roles: { project => role_without_permissions })
  end

  let!(:work_package) { create(:work_package, project:) }
  let!(:other_work_package) { create(:work_package, project:) }

  let!(:user_with_permissions_past_reminder) do
    Reminders::CreateService.new(user: user_with_permissions, contract_class: nil)
                           .call(remindable: work_package,
                                 remind_at: 1.day.ago,
                                 creator: user_with_permissions,
                                 note: "I'm the user with permissions and my reminder is in the past")
                           .result
  end
  let!(:user_with_permissions_future_reminder) do
    Reminders::CreateService.new(user: user_with_permissions, contract_class: nil)
                           .call(remindable: work_package,
                                 remind_at: 1.day.from_now,
                                 creator: user_with_permissions,
                                 note: "I'm the user with permissions and my reminder is in the future")
                           .result
  end
  let!(:user_with_permissions_future_reminder_in_other_work_package) do
    Reminders::CreateService.new(user: user_with_permissions, contract_class: nil)
                           .call(remindable: other_work_package,
                                 remind_at: 1.day.from_now,
                                 creator: user_with_permissions,
                                 note: "I'm the user with permissions and my reminder is in the future in another work package")
                           .result
  end
  let!(:other_user_without_permissions_reminder) do
    Reminders::CreateService.new(user: other_user_without_permissions, contract_class: nil)
                           .call(remindable: other_work_package,
                                 remind_at: 1.day.from_now,
                                 creator: other_user_without_permissions,
                                 note: "I'm the other user without permissions and my reminder is in the future")
                           .result
  end
  let!(:other_user_without_permissions_reminder_past) do
    Reminders::CreateService.new(user: other_user_without_permissions, contract_class: nil)
                           .call(remindable: other_work_package,
                                 remind_at: 1.day.ago,
                                 creator: other_user_without_permissions,
                                 note: "I'm the other user without permissions and my reminder is in the past")
                           .result
  end
  let!(:other_user_without_permissions_reminder_in_other_work_package) do
    Reminders::CreateService.new(user: other_user_without_permissions, contract_class: nil)
                           .call(remindable: other_work_package,
                                 remind_at: 1.day.from_now,
                                 creator: other_user_without_permissions,
                                 note: "I'm the other user without permissions and my reminder is in the" \
                                       "future in another work package")
                           .result
  end

  let(:href) { "/api/v3/work_packages/#{work_package.id}/reminders" }
  let(:request) { get href }
  let(:result) do
    request
    JSON.parse last_response.body
  end
  let(:subjects) { reminders.pluck("id") }

  def reminders
    result["_embedded"]["elements"]
  end

  context "with no permissions" do
    current_user { other_user_without_permissions }

    it "responds with unprocessable entity" do
      expect(result["errorIdentifier"]).to eq("urn:openproject-org:api:v3:errors:NotFound")
    end
  end

  context "with permissions" do
    current_user { user_with_permissions }

    it "returns the future reminders for the current user in the given work package" do
      expect(subjects).to contain_exactly(user_with_permissions_future_reminder.id)
    end
  end
end
