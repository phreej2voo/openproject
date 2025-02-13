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

module Reminders
  module ServiceHelpers
    extend ActiveSupport::Concern

    def reschedule_reminder(reminder)
      destroy_scheduled_reminder_job(reminder)
      mark_unread_notifications_as_read_for(reminder)
      schedule_new_reminder_job(reminder)
    end

    def schedule_new_reminder_job(reminder)
      job = Reminders::ScheduleReminderJob.schedule(reminder)
      reminder.update_columns(job_id: job.job_id)
    end

    def destroy_scheduled_reminder_job(reminder)
      return unless reminder.scheduled?
      return unless job = GoodJob::Job.find_by(id: reminder.job_id)

      job.destroy unless job.finished?
    end

    def mark_unread_notifications_as_read_for(reminder)
      return unless reminder.unread_notifications?

      reminder.unread_notifications.update_all(read_ian: true, updated_at: Time.zone.now)
    end
  end
end
