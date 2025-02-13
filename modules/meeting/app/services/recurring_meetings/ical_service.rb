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

module RecurringMeetings
  class ICalService
    include ::Meetings::ICalHelpers
    attr_reader :user,
                :series,
                :schedule,
                :timezone,
                :calendar,
                :url_helpers

    delegate :template, to: :series

    def initialize(series:, user:)
      @user = user
      @series = series
      @schedule = series.schedule
      @url_helpers = OpenProject::StaticRouting::StaticUrlHelpers.new
    end

    def generate_series
      ical_result(series) do
        series_event
        occurrences_events
      end
    rescue StandardError => e
      Rails.logger.error("Failed to generate ICS for meeting series #{series.id}: #{e.message}")
      ServiceResult.failure(message: e.message)
    end

    def generate_occurrence(meeting)
      # Get the time the meeting was scheduled to take place
      scheduled_meeting = meeting.scheduled_meeting
      ical_result(scheduled_meeting) do
        occurrence_event(scheduled_meeting.start_time, meeting)
      end
    rescue StandardError => e
      Rails.logger.error("Failed to generate ICS for meeting #{meeting.id}: #{e.message}")
      ServiceResult.failure(message: e.message)
    end

    private

    def ical_result(meeting)
      User.execute_as(user) do
        @timezone = Time.zone || Time.zone_default
        @calendar = build_icalendar(meeting.start_time)

        yield

        calendar.publish
        ServiceResult.success(result: calendar.to_ical)
      end
    end

    def tzinfo
      timezone.tzinfo
    end

    def tzid
      tzinfo.canonical_identifier
    end

    def series_event # rubocop:disable Metrics/AbcSize
      calendar.event do |e|
        base_series_attributes(e)

        e.rrule = schedule.rrules.first.to_ical # We currently only have one recurrence rule
        e.dtstart = ical_datetime template.start_time, tzid
        e.dtend = ical_datetime template.end_time, tzid
        e.url = url_helpers.project_recurring_meeting_url(series.project, series)
        e.location = template.location.presence

        add_attendees(e, template)
        e.exdate = cancelled_schedules
      end
    end

    def occurrences_events
      upcoming_instantiated_schedules.find_each do |schedule|
        occurrence_event(schedule.start_time, schedule.meeting)
      end
    end

    def occurrence_event(schedule_start_time, meeting) # rubocop:disable Metrics/AbcSize
      calendar.event do |e|
        base_series_attributes(e)

        e.recurrence_id = ical_datetime schedule_start_time, tzid
        e.dtstart = ical_datetime meeting.start_time, tzid
        e.dtend = ical_datetime meeting.end_time, tzid
        e.url = url_helpers.project_meeting_url(meeting.project, meeting)
        e.location = meeting.location.presence
        e.sequence = meeting.lock_version

        add_attendees(e, meeting)
      end
    end

    def upcoming_instantiated_schedules
      series
        .scheduled_meetings
        .not_cancelled
        .instantiated
        .includes(:meeting)
    end

    def base_series_attributes(event) # rubocop:disable Metrics/AbcSize
      event.uid = ical_uid("meeting-series-#{series.id}")
      event.summary = "[#{series.project.name}] #{series.title}"
      event.description = "[#{series.project.name}] #{I18n.t(:label_meeting_series)}: #{series.title}"
      event.organizer = ical_organizer(series)
    end

    def cancelled_schedules
      series
        .scheduled_meetings
        .cancelled
        .pluck(:start_time)
        .map { |time| Icalendar::Values::DateTime.new time.in_time_zone(tzid), "tzid" => tzid }
    end
  end
end
