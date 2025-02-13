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

module RecurringMeetings
  class UpdateContract < BaseContract
    include Redmine::I18n

    validate :user_allowed_to_edit
    validate :not_before_scheduled_time

    def user_allowed_to_edit
      unless user.allowed_in_project?(:edit_meetings, model.project)
        errors.add :base, :error_unauthorized
      end
    end

    def not_before_scheduled_time # rubocop:disable Metrics/AbcSize
      return unless model.changed.intersect?(%w[start_time start_date])

      if model.start_time < DateTime.now
        if model.start_time.to_date < Time.zone.today
          errors.add :start_date, :after, date: format_date(Date.yesterday)
        else
          errors.add :start_time_hour, :datetime_must_be_in_future
        end
      end
    end
  end
end
