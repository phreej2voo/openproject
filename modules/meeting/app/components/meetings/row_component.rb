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

module Meetings
  class RowComponent < ::OpPrimer::BorderBoxRowComponent
    delegate :current_project, to: :table

    def project_name
      helpers.link_to_project model.project, {}, {}, false
    end

    def title
      if recurring?
        link_to model.title, recurring_meeting_path(model)
      elsif recurring_meeting.present?
        occurrence_title
      else
        link_to model.title, project_meeting_path(model.project, model)
      end
    end

    def occurrence_title
      safe_join(
        [(link_to model.title, project_meeting_path(model.project, model)),
         (link_to recurring_label, recurring_meeting_path(recurring_meeting))], "  "
      )
    end

    def start_time
      if recurring?
        helpers.format_time(model.start_time, include_date: false)
      else
        safe_join([helpers.format_date(model.start_time), helpers.format_time(model.start_time, include_date: false)], " ")
      end
    end

    def duration
      render OpenProject::Common::DurationComponent.new(model.duration, :hours, abbreviated: false)
    end

    def location
      helpers.auto_link(recurring? ? model.template.location : model.location,
                        link: :all,
                        html: { target: "_blank" })
    end

    def frequency
      return unless recurring?

      model.human_frequency
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

        if recurring?
          nil
        elsif recurring_meeting.present?
          view_meeting_series(menu)
        else
          copy_action(menu)
        end

        ical_action(menu) unless recurring?
        delete_action(menu)
      end
    end

    def view_meeting_series(menu)
      menu.with_item(label: I18n.t(:label_recurring_meeting_view),
                     href: recurring_meeting_path(recurring_meeting)) do |item|
        item.with_leading_visual_icon(icon: :iterations)
      end
    end

    def copy_action(menu)
      return unless copy_allowed?

      menu.with_item(label: I18n.t(:label_meeting_copy),
                     href: copy_meeting_path(model),
                     content_arguments: {
                       data: {
                         turbo: model.is_a?(StructuredMeeting),
                         turbo_stream: true
                       }
                     }) do |item|
        item.with_leading_visual_icon(icon: :copy)
      end
    end

    def ical_action(menu)
      menu.with_item(label: I18n.t(:label_icalendar_download),
                     href: download_ics_meeting_path(model),
                     content_arguments: {
                       data: { turbo: false }
                     }) do |item|
        item.with_leading_visual_icon(icon: :download)
      end
    end

    def delete_action(menu)
      return unless delete_allowed?

      menu.with_item(label: recurring_meeting.present? ? I18n.t(:label_recurring_meeting_delete) : I18n.t(:label_meeting_delete),
                     scheme: :danger,
                     href: polymorphic_path([:delete_dialog, current_project, model.becomes(Meeting)]),
                     tag: :a,
                     content_arguments: {
                       data: { controller: "async-dialog" }
                     }) do |item|
        item.with_leading_visual_icon(icon: :trash)
      end
    end

    def recurring_label
      render(Primer::BaseComponent.new(tag: :span, color: :muted)) do
        concat render(Primer::Beta::Octicon.new(icon: :iterations, mr: 1, ml: 1))
        concat render(Primer::Beta::Text.new(font_weight: :bold, font_size: :small)) { recurring_meeting.human_frequency }
      end
    end

    def delete_allowed?
      User.current.allowed_in_project?(:delete_meetings, model.project)
    end

    def copy_allowed?
      User.current.allowed_in_project?(:create_meetings, model.project)
    end

    def recurring?
      model.is_a?(RecurringMeeting)
    end

    def recurring_meeting
      return if recurring?

      model.recurring_meeting
    end
  end
end
