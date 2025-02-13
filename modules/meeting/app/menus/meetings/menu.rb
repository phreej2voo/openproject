# -- copyright
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
# ++
module Meetings
  class Menu < Submenu
    def initialize(params:, project: nil)
      super(view_type: nil, project:, params:)
    end

    def menu_items
      [
        OpenProject::Menu::MenuGroup.new(header: nil, children: top_level_menu_items),
        OpenProject::Menu::MenuGroup.new(header: I18n.t(:label_meeting_series), children: meeting_series_menu_items),
        involvement_group
      ].compact
    end

    def top_level_menu_items
      [
        my_meetings_item,
        recurring_menu_item,
        all_meetings_item
      ].compact
    end

    def my_meetings_item
      return unless User.current.logged?

      my_meetings_href = polymorphic_path([project, :meetings])
      menu_item(title: I18n.t(:label_my_meetings),
                selected: params[:current_href] == my_meetings_href && params[:filters].blank?)
    end

    def all_meetings_item
      all_filter = [{ invited_user_id: { operator: "*", values: [] } }].to_json
      my_meetings_href = polymorphic_path([project, :meetings])

      menu_item(title: I18n.t(:label_all_meetings),
                selected: User.current.anonymous? && params[:current_href] == my_meetings_href && params[:filters].blank?,
                query_params: { filters: all_filter })
    end

    def meeting_series_menu_items
      series = RecurringMeeting
        .visible
        .reorder("LOWER(title)")

      if project
        series = series.where(project_id: project.id)
      end

      current_href = params[:current_href]
      current_recurring_meeting_id = extracted_id(current_href)

      series.pluck(:id, :title)
            .map do |id, title|
        href = polymorphic_path([project, :recurring_meeting], { id: })
        OpenProject::Menu::MenuItem.new(title:,
                                        selected: select_status(href, current_href, current_recurring_meeting_id),
                                        href:)
      end
    end

    def recurring_menu_item
      recurring_filter = [{ type: { operator: "=", values: ["t"] } }].to_json

      menu_item(title: I18n.t("label_recurring_meeting_plural"),
                query_params: { filters: recurring_filter, sort: "start_time" })
    end

    def involvement_group
      return unless User.current.logged?

      OpenProject::Menu::MenuGroup.new(header: I18n.t(:label_involvement), children: involvement_sidebar_menu_items)
    end

    def involvement_sidebar_menu_items
      invitation_filter = [{ invited_user_id: { operator: "=", values: [User.current.id.to_s] } }].to_json

      [
        menu_item(title: I18n.t(:label_invitations),
                  query_params: { filters: invitation_filter, sort: "start_time" }),
        menu_item(title: I18n.t(:label_attended),
                  query_params: { filters: attendee_filter, upcoming: false }),
        menu_item(title: I18n.t(:label_created_by_me),
                  query_params: { filters: author_filter })
      ]
    end

    def query_path(query_params)
      if project.present?
        project_meetings_path(project, params.permit(query_params.keys).merge!(query_params))
      else
        meetings_path(params.permit(query_params.keys).merge!(query_params))
      end
    end

    def past_filter
      [
        { time: { operator: "=", values: ["past"] } },
        { invited_user_id: { operator: "=", values: [User.current.id.to_s] } }
      ].to_json
    end

    def attendee_filter
      [{ attended_user_id: { operator: "=", values: [User.current.id.to_s] } }].to_json
    end

    def author_filter
      [{ author_id: { operator: "=", values: [User.current.id.to_s] } }].to_json
    end

    def recurring_meeting_type_filter
      [{ type: { operator: "=", values: [RecurringMeeting.to_s] } }].to_json
    end

    def extracted_id(current_href)
      current_meeting_id = current_href.split("/").last.to_i if current_href&.match(/\/meetings\/\d+$/)

      Meeting.find(current_meeting_id).recurring_meeting_id if current_meeting_id
    end

    def select_status(href, current_href, current_recurring_meeting_id = nil)
      return current_href == href unless current_recurring_meeting_id && !href.is_a?(Hash)

      href_meeting_id = href.split("/").last.to_i

      current_recurring_meeting_id == href_meeting_id
    end
  end
end
