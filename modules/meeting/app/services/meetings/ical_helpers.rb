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
require "icalendar"
require "icalendar/tzinfo"

module Meetings
  module ICalHelpers
    def ical_event(start_time, &)
      calendar = build_icalendar(start_time)
      calendar.event(&)
      calendar.publish
      calendar.to_ical
    end

    def build_icalendar(start_time)
      ::Icalendar::Calendar.new.tap do |calendar|
        calendar.prodid = "-//OpenProject GmbH//#{OpenProject::VERSION}//Meeting//EN"
        ical_timezone = timezone.tzinfo.ical_timezone start_time
        calendar.add_timezone ical_timezone
      end
    end

    def add_attendees(event, meeting)
      meeting.participants.includes(:user).find_each do |participant|
        user = participant.user
        next unless user

        address = Icalendar::Values::CalAddress.new(
          "mailto:#{user.mail}",
          {
            "CN" => user.name,
            "EMAIL" => user.mail,
            "PARTSTAT" => "NEEDS-ACTION",
            "RSVP" => "TRUE",
            "CUTYPE" => "INDIVIDUAL",
            "ROLE" => "REQ-PARTICIPANT"
          }
        )

        event.append_attendee(address)
      end
    end

    def ical_uid(suffix)
      "#{Setting.app_title}-#{Setting.host_name}-#{suffix}".dasherize
    end

    def ical_datetime(time, timezone_id)
      Icalendar::Values::DateTime.new time.in_time_zone(timezone_id), "tzid" => timezone_id
    end

    def ical_organizer(meeting)
      Icalendar::Values::CalAddress.new("mailto:#{meeting.author.mail}", cn: meeting.author.name)
    end
  end
end
