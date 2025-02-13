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

class RemoveIncorrectManageOwnRemindersPermission < ActiveRecord::Migration[7.1]
  def up
    # Remove manage_own_reminders permission from non member and anonymous roles
    # Use hardcoded values for `Role::BUILTIN_NON_MEMBER` and `Role::BUILTIN_ANONYMOUS`
    # to avoid breaking the migration if the values are changed in the future
    non_member_builtin = 1 # Role::BUILTIN_NON_MEMBER
    anonymous_builtin = 2 # Role::BUILTIN_ANONYMOUS
    execute <<-SQL.squish
      DELETE FROM role_permissions
      WHERE role_id IN (
        SELECT id FROM roles WHERE builtin IN (#{non_member_builtin}, #{anonymous_builtin})
      )
      AND permission = 'manage_own_reminders'
    SQL

    # Remove all reminders created by anonymous user and cascade delete related records
    execute <<-SQL.squish
      WITH deleted_reminders AS (
        DELETE FROM reminders
        WHERE creator_id IN (
          SELECT id FROM users WHERE type = 'AnonymousUser'
        )
        RETURNING id
      ),
      deleted_reminder_notifications AS (
        DELETE FROM reminder_notifications
        WHERE reminder_id IN (SELECT id FROM deleted_reminders)
        RETURNING notification_id
      )
      DELETE FROM notifications
      WHERE id IN (SELECT notification_id FROM deleted_reminder_notifications)
    SQL
  end

  # No-op
  def down; end
end
