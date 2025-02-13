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

module RecurringMeetings
  class RowComponent < ::OpPrimer::BorderBoxRowComponent
    delegate :meeting, to: :model
    delegate :cancelled?, to: :model
    delegate :recurring_meeting, to: :model
    delegate :project, to: :recurring_meeting
    delegate :schedule, to: :meeting
    delegate :current_project, to: :table

    def instantiated?
      meeting.present?
    end

    def column_args(column)
      if column == :title
        { style: "grid-column: span 2" }
      else
        super
      end
    end

    def start_time
      if instantiated?
        link_to start_time_title, current_project_meeting_path(meeting)
      else
        start_time_title
      end
    end

    def current_project_meeting_path(meeting)
      if current_project
        project_meeting_path(current_project, meeting)
      else
        meeting_path(meeting)
      end
    end

    def user_time_zone(time)
      helpers.in_user_zone(time)
    end

    def formatted_time(time)
      helpers.format_time(user_time_zone(time), include_date: true)
    end

    def old_time
      render(Primer::Beta::Text.new(tag: :s)) { formatted_time(model.start_time) }
    end

    def start_time_title
      if start_time_changed?
        old_time + simple_format("\n#{formatted_time(meeting.start_time)}")
      else
        formatted_time(model.start_time)
      end
    end

    def relative_time
      time = start_time_changed? ? meeting.start_time : model.start_time

      render(OpPrimer::RelativeTimeComponent.new(datetime: user_time_zone(time), prefix: I18n.t(:label_on)))
    end

    def state
      if model.cancelled?
        "cancelled"
      elsif instantiated?
        meeting.state
      else
        "planned"
      end
    end

    def status
      scheme = status_scheme(state)

      render(Primer::Beta::Label.new(title:, scheme:)) do
        render(Primer::Beta::Text.new) { t("label_meeting_state_#{state}") }
      end
    end

    def status_scheme(state)
      case state
      when "open"
        :success
      when "cancelled"
        :severe
      else
        :secondary
      end
    end

    def create
      return unless copy_allowed?
      return if instantiated? || cancelled?

      render(
        Primer::Beta::Button.new(
          scheme: :default,
          size: :medium,
          tag: :a,
          data: { "turbo-method": "post" },
          href: init_recurring_meeting_path(model.recurring_meeting.id, start_time: model.start_time.iso8601)
        )
      ) do |_c|
        I18n.t(:label_recurring_meeting_create)
      end
    end

    def button_links
      [
        action_menu
      ]
    end

    def action_menu
      render(Primer::Alpha::ActionMenu.new) do |menu|
        menu.with_show_button(icon: "kebab-horizontal",
                              "aria-label": "More",
                              scheme: :invisible,
                              data: {
                                "test-selector": "more-button"
                              })

        delete_scheduled_action(menu)
        ical_action(menu)
        delete_action(menu)
        restore_action(menu)
      end
    end

    def ical_action(menu)
      return unless instantiated? && !cancelled?

      menu.with_item(label: I18n.t(:label_icalendar_download),
                     href: download_ics_recurring_meeting_path(model.recurring_meeting, occurrence_id: model.id),
                     content_arguments: {
                       data: { turbo: false }
                     }) do |item|
        item.with_leading_visual_icon(icon: :download)
      end
    end

    def delete_action(menu)
      return unless delete_allowed? && !cancelled? && instantiated?

      menu.with_item(
        label: past? ? I18n.t(:label_recurring_meeting_delete) : I18n.t(:label_recurring_meeting_cancel),
        scheme: :danger,
        href: polymorphic_path([:delete_dialog, current_project, meeting.becomes(Meeting)]),
        tag: :a,
        content_arguments: {
          data: { controller: "async-dialog" }
        }
      ) do |item|
        item.with_leading_visual_icon(icon: :trash)
      end
    end

    def delete_scheduled_action(menu)
      return unless delete_allowed? && !cancelled? && !instantiated?

      menu.with_item(
        label: I18n.t(:label_recurring_meeting_cancel),
        scheme: :danger,
        href: polymorphic_path([:delete_scheduled_dialog, current_project, model.recurring_meeting],
                               start_time: model.start_time.iso8601),
        tag: :a,
        content_arguments: {
          data: { controller: "async-dialog" }
        }
      ) do |item|
        item.with_leading_visual_icon(icon: :trash)
      end
    end

    def restore_action(menu)
      return unless cancelled?

      menu.with_item(
        label: I18n.t(:label_recurring_meeting_restore),
        href: init_recurring_meeting_path(recurring_meeting, start_time: model.start_time.iso8601),
        form_arguments: {
          method: :post
        }
      ) do |item|
        item.with_leading_visual_icon(icon: :history)
      end
    end

    def delete_allowed?
      User.current.allowed_in_project?(:delete_meetings, project)
    end

    def copy_allowed?
      User.current.allowed_in_project?(:create_meetings, project)
    end

    def start_time_changed?
      meeting && meeting.start_time != model.start_time
    end

    def past?
      model.start_time < Time.current
    end
  end
end
