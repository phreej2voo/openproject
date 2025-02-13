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
module CostReports
  class Menu < Submenu
    attr_reader :view_type, :project

    def initialize(project: nil, params: nil)
      @project = project
      @params = params

      super(view_type:, project:, params:)
    end

    def menu_items
      [
        OpenProject::Menu::MenuGroup.new(header: I18n.t("label_public_report_plural"), children: global_queries),
        OpenProject::Menu::MenuGroup.new(header: I18n.t("label_private_report_plural"), children: custom_queries)
      ]
    end

    def global_queries
      CostQuery.public(project)
        .pluck(:id, :name)
        .map { |id, name| menu_item(title: name, query_params: query_params(id)) }
        .sort_by { |item| item.title.downcase }
    end

    def custom_queries
      CostQuery.private(project, User.current)
        .pluck(:id, :name)
        .map { |id, name| menu_item(title: name, query_params: query_params(id)) }
        .sort_by { |item| item.title.downcase }
    end

    def selected?(query_params)
      query_params[:id].to_s == params[:id]
    end

    def query_params(id)
      { id: }
    end

    def query_path(query_params)
      if project.present?
        project_cost_report_path(project, query_params)
      else
        global_cost_report_path(query_params)
      end
    end
  end
end
