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

module OpenProject
  class CustomFieldFormat
    include Redmine::I18n

    cattr_reader :available
    @@available = {}

    attr_reader :name, :order, :label, :edit_as, :class_names

    def initialize(name,
                   label:,
                   order:,
                   edit_as: name,
                   only: nil,
                   multi_value_possible: false,
                   formatter: "CustomValue::StringStrategy")
      @name = name
      @label = label
      @order = order
      @edit_as = edit_as
      @class_names = only
      @multi_value_possible = multi_value_possible
      @formatter = formatter
    end

    def multi_value_possible?
      @multi_value_possible
    end

    def formatter
      # avoid using stale definitions in dev mode
      Kernel.const_get(@formatter)
    end

    class << self
      def map(&)
        yield self
      end

      # Registers a custom field format
      def register(custom_field_format, _options = {})
        @@available[custom_field_format.name] = custom_field_format unless @@available.include?(custom_field_format.name)
      end

      def available_formats
        @@available.keys
      end

      def find_by(name:)
        @@available[name.to_s]
      end

      def all_for_field(custom_field)
        class_name = custom_field.class.customized_class.name
        all_for_class_name(class_name)
      end

      def all_for_class_name(class_name)
        available
          .values
          .select { |field| field.class_names.nil? || field.class_names.include?(class_name) }
          .sort_by(&:order)
          .reject { |format| format.label.nil? }
      end
    end
  end
end
