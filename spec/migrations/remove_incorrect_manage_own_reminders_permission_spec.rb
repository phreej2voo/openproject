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
require Rails.root.join("db/migrate/20250108100511_remove_incorrect_manage_own_reminders_permission.rb")

RSpec.describe RemoveIncorrectManageOwnRemindersPermission, type: :model do
  let(:permissions) { %i[permission1 permission2 manage_own_reminders] }
  let(:non_member) { create(:non_member, permissions:) }
  let(:anonymous) { create(:anonymous_role, permissions:) }
  let(:other_role) { create(:work_package_role, permissions:) }

  let(:anonymous_user_reminder) do
    create(:reminder, :with_unread_notifications, creator: AnonymousUser.first)
  end

  let(:normal_user_reminder) { create(:reminder, :with_unread_notifications) }

  it "removes the `manage_own_reminders` permission from non member and anonymous roles" do
    expect(non_member.permissions).to include(:manage_own_reminders)
    expect(anonymous.permissions).to include(:manage_own_reminders)
    expect(other_role.permissions).to include(:manage_own_reminders)

    expect(anonymous_user_reminder).to be_persisted
    expect(normal_user_reminder.creator).to be_persisted

    expect do
      ActiveRecord::Migration.suppress_messages { described_class.migrate(:up) }
    end.to(
      change(RolePermission, :count).by(-2) &
        change(Reminder, :count).by(-1) &
        change(ReminderNotification, :count).by(-1) &
        change(Notification, :count).by(-1)
    )

    expect(non_member.reload.permissions).not_to include(:manage_own_reminders)
    expect(anonymous.reload.permissions).not_to include(:manage_own_reminders)
    expect(other_role.reload.permissions).to include(:manage_own_reminders)

    reminder_creators = Reminder.pluck(:creator_id)
    expect(reminder_creators).not_to include(AnonymousUser.first.id)
    expect(reminder_creators).to include(normal_user_reminder.creator_id)
  end
end
