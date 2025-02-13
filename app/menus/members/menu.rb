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
module Members
  class Menu < Submenu
    attr_reader :project, :params

    def initialize(project: nil, params: nil)
      super(view_type: nil, project:, params:)
    end

    def menu_items
      [
        OpenProject::Menu::MenuGroup.new(header: nil, children: user_status_options),
        OpenProject::Menu::MenuGroup.new(header: I18n.t("members.menu.project_roles"), children: project_roles_entries),
        OpenProject::Menu::MenuGroup.new(header: I18n.t("members.menu.wp_shares"), children: permission_menu_entries),
        OpenProject::Menu::MenuGroup.new(header: I18n.t("members.menu.groups"), children: project_group_entries)
      ]
    end

    def user_status_options
      [
        OpenProject::Menu::MenuItem.new(title: I18n.t("members.menu.all"),
                                        href: project_members_path(project),
                                        selected: active_filter_count == 0),
        menu_item(title: I18n.t("members.menu.locked"), query_params: { status: :locked }),
        menu_item(title: I18n.t("members.menu.invited"), query_params: { status: :invited })
      ]
    end

    def project_roles_entries
      ProjectRole
        .where(id: MemberRole.where(member_id: @project.members.select(:id)).select(:role_id))
        .distinct
        .pluck(:id, :name)
        .map { |id, name| menu_item(title: name, query_params: { role_id: id }) }
    end

    def permission_menu_entries
      Members::UserFilterComponent
        .share_options
        .map { |name, id| menu_item(title: name, query_params: { shared_role_id: id }) }
    end

    def project_group_entries
      @project
        .groups
        .order(lastname: :asc)
        .distinct
        .pluck(:id, :lastname)
        .map { |id, name| menu_item(title: name, query_params: { group_id: id }) }
    end

    def selected?(query_params)
      return false if active_filter_count > 1

      super
    end

    def query_path(query_params)
      project_members_path(project, query_params)
    end

    def active_filter_count
      @active_filter_count ||= (params.keys & Members::UserFilterComponent.filter_param_keys.map(&:to_s)).count
    end
  end
end
