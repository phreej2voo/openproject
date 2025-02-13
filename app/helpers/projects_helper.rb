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

module ProjectsHelper
  include WorkPackagesFilterHelper

  PROJECTS_QUERY_PARAM_NAMES = %i[query_id filters columns sortBy per_page page].freeze
  PROJECTS_FILTER_FOR_COLUMN_MAPPING = {
    "description" => nil,
    "identifier" => nil,
    "name" => "id",
    "project_status" => "project_status_code",
    "required_disk_space" => nil,
    "status_explanation" => nil
  }.freeze

  # Just like sort_header tag but removes sorting by
  # lft from the sort criteria as lft is mutually exclusive with
  # the other criteria.
  def projects_sort_header_tag(column, all_column_attributes, **)
    former_criteria = @sort_criteria.criteria.dup

    @sort_criteria.criteria.reject! { |a, _| a == "lft" }

    sort_header_with_action_menu(column, all_column_attributes, PROJECTS_FILTER_FOR_COLUMN_MAPPING, **,
                                 allowed_params: projects_query_param_names_for_sort)
  ensure
    @sort_criteria.criteria = former_criteria
  end

  def short_project_description(project, length = 255)
    if project.description.blank?
      return ""
    end

    project.description.gsub(/\A(.{#{length}}[^\n\r]*).*\z/m, '\1...').strip
  end

  def projects_columns_options
    @projects_columns_options ||= ::ProjectQuery
                                    .new
                                    .available_selects
                                    .reject { |c| c.attribute == :hierarchy }
                                    .sort_by(&:caption)
                                    .map { |c| { id: c.attribute, name: c.caption } }
  end

  def selected_projects_columns_options
    Setting
      .enabled_projects_columns
      .filter_map { |c| projects_columns_options.find { |o| o[:id].to_s == c } }
  end

  def protected_projects_columns_options
    projects_columns_options
      .select { |c| c[:id] == :name }
  end

  def projects_query_param_names_for_sort = PROJECTS_QUERY_PARAM_NAMES - %i[sortBy page]

  def projects_query_params
    safe_query_params(PROJECTS_QUERY_PARAM_NAMES)
  end
end
