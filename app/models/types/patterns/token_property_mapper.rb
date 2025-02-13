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

module Types
  module Patterns
    class TokenPropertyMapper
      DEFAULT_FUNCTION = ->(key, context) { context.public_send(key.to_sym) }.curry

      TOKEN_PROPERTY_MAP = IceNine.deep_freeze(
        {
          accountable: { fn: ->(wp) { wp.responsible&.name }, label: -> { WorkPackage.human_attribute_name(:responsible) } },
          assignee: { fn: ->(wp) { wp.assigned_to&.name }, label: -> { WorkPackage.human_attribute_name(:assigned_to) } },
          author: { fn: ->(wp) { wp.author&.name }, label: -> { WorkPackage.human_attribute_name(:author) } },
          category: { fn: ->(wp) { wp.category&.name }, label: -> { WorkPackage.human_attribute_name(:category) } },
          creation_date: { fn: ->(wp) { wp.created_at }, label: -> { WorkPackage.human_attribute_name(:created_at) } },
          estimated_time: { fn: ->(wp) { wp.estimated_hours }, label: -> { WorkPackage.human_attribute_name(:estimated_hours) } },
          finish_date: { fn: ->(wp) { wp.due_date }, label: -> { WorkPackage.human_attribute_name(:due_date) } },
          parent: { fn: ->(wp) { wp.parent&.id }, label: -> { WorkPackage.human_attribute_name(:parent) } },
          parent_author: { fn: ->(wp) { wp.parent&.author&.name }, label: -> { WorkPackage.human_attribute_name(:author) } },
          parent_category: { fn: ->(wp) { wp.parent&.category&.name },
                             label: -> { WorkPackage.human_attribute_name(:category) } },
          parent_creation_date: { fn: ->(wp) { wp.parent&.created_at },
                                  label: -> { WorkPackage.human_attribute_name(:created_at) } },
          parent_estimated_time: { fn: ->(wp) { wp.parent&.estimated_hours },
                                   label: -> { WorkPackage.human_attribute_name(:estimated_hours) } },
          parent_finish_date: { fn: ->(wp) { wp.parent&.due_date },
                                label: -> { WorkPackage.human_attribute_name(:due_date) } },
          parent_priority: { fn: ->(wp) { wp.parent&.priority }, label: -> { WorkPackage.human_attribute_name(:priority) } },
          priority: { fn: ->(wp) { wp.priority }, label: -> { WorkPackage.human_attribute_name(:priority) } },
          project: { fn: ->(wp) { wp.project_id }, label: -> { WorkPackage.human_attribute_name(:project) } },
          project_active: { fn: ->(wp) { wp.project&.active? }, label: -> { Project.human_attribute_name(:active) } },
          project_name: { fn: ->(wp) { wp.project&.name }, label: -> { Project.human_attribute_name(:name) } },
          project_status: { fn: ->(wp) { wp.project&.status_code }, label: -> { Project.human_attribute_name(:status_code) } },
          project_parent: { fn: ->(wp) { wp.project&.parent_id }, label: -> { Project.human_attribute_name(:parent) } },
          project_public: { fn: ->(wp) { wp.project&.public? }, label: -> { Project.human_attribute_name(:public) } },
          start_date: { fn: ->(wp) { wp.start_date }, label: -> { WorkPackage.human_attribute_name(:start_date) } },
          status: { fn: ->(wp) { wp.status&.name }, label: -> { WorkPackage.human_attribute_name(:status) } },
          type: { fn: ->(wp) { wp.type&.name }, label: -> { WorkPackage.human_attribute_name(:type) } }
        }
      )

      def fetch(key)
        TOKEN_PROPERTY_MAP.dig(key, :fn) || DEFAULT_FUNCTION.call(key)
      end

      alias :[] :fetch

      def tokens_for_type(type)
        base = default_tokens
        base[:work_package].merge!(tokenize(work_package_cfs_for(type)))
        base[:project].merge!(tokenize(project_attributes, "project_"))
        base[:parent].merge!(tokenize(all_work_package_cfs, "parent_"))

        base.transform_values { _1.sort_by(&:last).to_h }
      end

      private

      def default_tokens
        TOKEN_PROPERTY_MAP.keys.each_with_object({ project: {}, work_package: {}, parent: {} }) do |key, obj|
          label = TOKEN_PROPERTY_MAP.dig(key, :label).call

          case key.to_s
          when /^project_/
            obj[:project][key] = label
          when /^parent_/
            obj[:parent][key] = label
          else
            obj[:work_package][key] = label
          end
        end
      end

      def tokenize(custom_field_scope, prefix = nil)
        custom_field_scope.pluck(:name, :id).to_h { |name, id| [:"#{prefix}custom_field_#{id}", name] }
      end

      def work_package_cfs_for(type)
        all_work_package_cfs.where(type: type)
      end

      def all_work_package_cfs
        WorkPackageCustomField.where(multi_value: false).where.not(field_format: %w[text bool link empty]).order(:name)
      end

      def project_attributes
        ProjectCustomField.where.not(field_format: %w[text bool link empty])
                          .where(admin_only: false, multi_value: false).order(:name)
      end
    end
  end
end
