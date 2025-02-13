# frozen_string_literal: true

#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2024 the OpenProject GmbH
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
  module ColumnType
    # Column to add properties to work packages like "follows wp1 with lag 2".
    #
    # Supported properties:
    #   - follows :wp
    #   - follows :wp with lag :int
    #
    # Example:
    #
    #   | subject   | properties              |
    #   | main      |                         |
    #   | follower  | follows main with lag 2 |
    #   | follower2 | follows follower        |
    #
    # Adapted from original implementation in `spec/support/schedule_helpers/chart_builder.rb`.
    class Properties < Generic
      def attributes_for_work_package(_attribute, _work_package)
        {}
      end

      def extract_data(_attribute, raw_header, work_package_data, _work_packages_data)
        properties = work_package_data.dig(:row, raw_header)
        properties = properties.split(",").map(&:strip).compact_blank
        parse_properties(properties)
      end

      def parse_properties(properties)
        properties.reduce({}) do |data, property|
          case parse_property(property)
          in {relations: relation}
            data[:relations] ||= []
            data[:relations] << relation
          end
          data
        end
      end

      def relations_for_raw_value(raw_value)
        raw_value.split
        {}
      end

      def parse_property(property)
        case property
        when /^follows (\w+)(?: with lag (\d+))?/
          {
            relations: {
              raw: property,
              type: :follows,
              predecessor: $1,
              lag: $2.to_i
            }
          }
        else
          spell_checker = DidYouMean::SpellChecker.new(
            dictionary: [
              "follows :wp",
              "follows :wp with lag :int"
            ]
          )
          suggestions = spell_checker.correct(property).map(&:inspect).join(" ")
          did_you_mean = " Did you mean #{suggestions} instead?" if suggestions.present?
          raise "unable to parse property #{property.inspect}.#{did_you_mean}"
        end
      end
    end
  end
end
