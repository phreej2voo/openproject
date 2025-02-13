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

module TableHelpers
  class TableParser
    def parse(representation)
      work_packages_data = parse_representation(representation)
      populate_work_package_data(work_packages_data)
    end

    def parse_representation(representation)
      headers, *rows = representation.split("\n").filter_map { |line| split_line_into_cells(line) }
      rows.map.with_index do |cells, index|
        if cells.size > headers.size
          raise ArgumentError, "Too many cells in row #{index + 1}, have you forgotten some headers?"
        end

        cells << "" while cells.size < headers.size
        {
          attributes: {},
          index:,
          row: headers.zip(cells).to_h
        }
      end
    end

    private

    def populate_work_package_data(work_packages_data)
      columns(work_packages_data).each do |column|
        column.read_and_update_work_packages_data(work_packages_data)
      end
      work_packages_data
    end

    def headers(work_packages_data)
      work_packages_data.first[:row].keys
    end

    def columns(work_packages_data)
      work_packages_data.first[:row].keys.map { |key| Column.for(key) }
    end

    def split_line_into_cells(line)
      case line
      when "", /^\s*#/
        # noop
      else
        split(line)
      end
    end

    def split(line)
      (line || "").split("|").reject(&:empty?)
    end
  end
end
