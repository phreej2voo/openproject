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

module Meetings
  module DemoData
    class MeetingSeriesSeeder < ::BasicData::ModelSeeder
      self.model_class = RecurringMeeting
      self.seed_data_model_key = "meeting_series"

      attr_reader :project

      def initialize(project, seed_data)
        super(seed_data)
        @project = project
      end

      def prepare!
        project.enabled_modules << EnabledModule.new(name: "meetings")
      end

      def create_model!(model_data)
        series = super
        create_meeting_template!(series, model_data)
        RecurringMeetings::InitNextOccurrenceJob.perform_later(series, series.first_occurrence)
      end

      def create_meeting_template!(series, model_data)
        template = StructuredMeeting.new(template_attributes(model_data))
        template.template = true
        template.recurring_meeting = series

        template.save!
        reference = :"#{model_data['reference']}_template"
        seed_data.store_reference(reference, template)
      end

      def model_attributes(meeting_data)
        {
          title: meeting_data["title"],
          author: seed_data.find_reference(meeting_data["author"]),
          duration: minutes_to_hours(meeting_data["duration"]),
          start_time: Time.current.next_weekday + 10.hours,
          frequency: meeting_data["frequency"],
          interval: meeting_data["interval"],
          project:
        }
      end

      def template_attributes(meeting_data)
        model_attributes(meeting_data)
          .slice(:title, :author, :duration, :start_time, :project)
      end

      def minutes_to_hours(duration)
        duration && (duration / 60.0)
      end
    end
  end
end
