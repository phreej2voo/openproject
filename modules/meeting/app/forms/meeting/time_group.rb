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

class Meeting::TimeGroup < ApplicationForm
  include Redmine::I18n

  form do |meeting_form|
    meeting_form.group(layout: :horizontal) do |group|
      group.text_field(
        name: :start_date,
        type: "date",
        value: @initial_date,
        placeholder: @meeting.class.human_attribute_name(:start_date),
        label: @meeting.class.human_attribute_name(:start_date),
        required: true,
        autofocus: false,
        data: {
          action: "input->recurring-meetings--form#updateFrequencyText"
        }
      )

      group.text_field(
        name: :start_time_hour,
        type: "time",
        value: @initial_time,
        placeholder: Meeting.human_attribute_name(:start_time),
        label: Meeting.human_attribute_name(:start_time),
        required: true,
        caption: formatted_time_zone_offset,
        data: {
          action: "input->recurring-meetings--form#updateFrequencyText"
        }
      )
      group.text_field(
        name: :duration,
        type: :text,
        value: @duration,
        placeholder: Meeting.human_attribute_name(:duration),
        label: Meeting.human_attribute_name(:duration),
        visually_hide_label: false,
        required: true,
        caption: I18n.t("text_in_hours"),
        data: {
          controller: "chronic-duration",
          application_target: "dynamic"
        }
      )
    end
  end

  def initialize(meeting:)
    super()

    @meeting = meeting
    @initial_time = meeting.start_time_hour.presence || format_time(meeting.start_time, include_date: false, format: "%H:%M")
    @initial_date = meeting.start_date.presence || format_time_as_date(meeting.start_time, format: "%Y-%m-%d")

    duration = duration_value(meeting)
    @duration = duration.nil? ? "" : ChronicDuration.output(duration * 3600, format: :hours_only)
  end

  private

  def duration_value(meeting)
    if meeting.is_a?(RecurringMeeting) && meeting.template
      meeting.template.duration
    else
      meeting.duration
    end
  end
end
