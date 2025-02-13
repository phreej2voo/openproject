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
  class TableRepresenter
    attr_reader :tables_data, :columns

    def initialize(tables_data:, columns:)
      @tables_data = tables_data
      @columns = columns
    end

    def render(table_data)
      columns
        .map { |column| formatted_cells_for_column(column, table_data) }
        .transpose
        .map { |row| "| #{row.join(' | ')} |\n" }
        .join
    end

    def formatted_cells_for_column(column, table_data)
      get_header_and_values(column, table_data)
        .then { |cells| normalize_width(cells, column) }
    end

    def get_header_and_values(column, table_data)
      if column.attribute == :schedule
        header = schedule_column_representer.column_title
        start_dates = table_data.values_for_attribute(:start_date)
        due_dates = table_data.values_for_attribute(:due_date)
        values = start_dates.zip(due_dates).map do |start_date, due_date|
          schedule_column_representer.span(start_date, due_date)
        end
      else
        header = column.title
        values = table_data
          .values_for_attribute(column.attribute)
          .map! { column.format(_1) }
      end
      [header, *values]
    end

    def normalize_width(cells, column)
      header, *values = cells
      width = column_width(column)
      header = header.ljust(width)
      values.map! { column.align(_1, width) }
      [header, *values]
    end

    private

    def column_width(column)
      column_widths[column]
    end

    # Calculate the width of each column given values from all tables data.
    def column_widths
      @column_widths ||=
        columns.index_with do |column|
          if column.attribute == :schedule
            schedule_column_representer.column_size
          else
            values = tables_data.flat_map { _1.values_for_attribute(column.attribute) }
            values_max_size = values.map { column.format(_1).size }.max
            [column.title.size, values_max_size].max
          end
        end
    end

    def schedule_column_representer
      @schedule_column_representer ||= begin
        start_dates = tables_data.flat_map { _1.values_for_attribute(:start_date) }
        due_dates = tables_data.flat_map { _1.values_for_attribute(:due_date) }
        ScheduleColumnFormatter.new(start_dates, due_dates)
      end
    end

    class ScheduleColumnFormatter
      attr_reader :monday, :first_day, :last_day

      def initialize(start_dates, due_dates)
        @monday = Date.current.next_occurring(:monday)
        all_dates = start_dates + due_dates + [@monday, @monday + 6]
        @first_day, @last_day = all_dates.flatten.compact.minmax
      end

      def column_size
        (first_day..last_day).count
      end

      def column_title
        spaced_at(monday, "MTWTFSS")
      end

      def span(start_date, due_date)
        if start_date.nil? && due_date.nil?
          " " * column_size
        elsif due_date.nil?
          spaced_at(start_date, "[")
        elsif start_date.nil?
          spaced_at(due_date, "]")
        else
          span = "X" * (start_date..due_date).count
          spaced_at(start_date, span)
        end
      end

      def spaced_at(date, text)
        nb_days = date - first_day
        spaced = (" " * nb_days) + text
        spaced.ljust(column_size)
      end
    end
  end
end
