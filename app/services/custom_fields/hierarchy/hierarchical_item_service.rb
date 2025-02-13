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

module CustomFields
  module Hierarchy
    class HierarchicalItemService
      include Dry::Monads[:result]

      # Generate the root item for the CustomField of type hierarchy
      # @param custom_field [CustomField] custom field of type hierarchy
      # @return [Success(CustomField::Hierarchy::Item), Failure(Dry::Validation::Result), Failure(ActiveModel::Errors)]
      def generate_root(custom_field)
        CustomFields::Hierarchy::GenerateRootContract
          .new
          .call(custom_field:)
          .to_monad
          .bind { |validation| create_root_item(validation[:custom_field]) }
      end

      # Insert a new node on the hierarchy tree at a desired position or at the end if no sort_order is passed.
      # @param parent [CustomField::Hierarchy::Item] the parent of the node
      # @param label [String] the node label/name that must be unique at the same tree level
      # @param short [String] an alias for the node
      # @param sort_order [Integer] the position into which insert the item.
      # @return [Success(CustomField::Hierarchy::Item), Failure(Dry::Validation::Result), Failure(ActiveModel::Errors)]
      def insert_item(parent:, label:, short: nil, sort_order: nil)
        CustomFields::Hierarchy::InsertItemContract
          .new
          .call({ parent:, label:, short: }.compact)
          .to_monad
          .bind { |validation| create_child_item(validation:, sort_order:) }
      end

      # Updates an item/node
      # @param item [CustomField::Hierarchy::Item] the item to be updated
      # @param label [String] the node label/name that must be unique at the same tree level
      # @param short [String] an alias for the node
      # @return [Success(CustomField::Hierarchy::Item), Failure(Dry::Validation::Result), Failure(ActiveModel::Errors)]
      def update_item(item:, label: nil, short: nil)
        CustomFields::Hierarchy::UpdateItemContract
          .new
          .call({ item:, label:, short: }.compact)
          .to_monad
          .bind { |attributes| update_item_attributes(item:, attributes:) }
      end

      # Delete an entire branch of the hierarchy/tree
      # @param item [CustomField::Hierarchy::Item] the parent of the node
      # @return [Success(CustomField::Hierarchy::Item), Failure(Symbol), Failure(ActiveModel::Errors)]
      def delete_branch(item:)
        return Failure(:item_is_root) if item.root?

        item.destroy ? Success() : Failure(item.errors)
      end

      # Gets all nodes in a tree from the item/node back to the root.
      # Ordered from root to leaf
      # @param item [CustomField::Hierarchy::Item] the parent of the node
      # @return [Success(Array<CustomField::Hierarchy::Item>)]
      def get_branch(item:)
        Success(item.self_and_ancestors.reverse)
      end

      # Gets all descendant nodes in a tree starting from the item/node.
      # @param item [CustomField::Hierarchy::Item] the node
      # @param include_self [Boolean] flag
      # @return [Success(Array<CustomField::Hierarchy::Item>)]
      def get_descendants(item:, include_self: true)
        if include_self
          Success(item.self_and_descendants)
        else
          Success(item.descendants)
        end
      end

      # Move an item/node to a new parent item/node
      # @param item [CustomField::Hierarchy::Item] the parent of the node
      # @param new_parent [CustomField::Hierarchy::Item] the new parent of the node
      # @return [Success(CustomField::Hierarchy::Item)]
      def move_item(item:, new_parent:)
        updated_item = new_parent.append_child(item)
        update_position_cache(new_parent.root)

        Success(updated_item)
      end

      # Reorder the item along its siblings.
      # @param item [CustomField::Hierarchy::Item] the parent of the node
      # @param new_sort_order [Integer] the new position of the node
      # @return [Success]
      def reorder_item(item:, new_sort_order:)
        return Success() if item.siblings.empty?

        new_sort_order = [0, new_sort_order.to_i].max
        return Success() if item.sort_order == new_sort_order

        update_item_order(item:, new_sort_order:)

        Success()
      end

      def soft_delete_item(item:)
        # Soft delete the item and children
        raise NotImplementedError
      end

      # Returns a hash of Item => { Item => [Item] }
      # @param item [CustomField::Hierarchy::Item] the start node
      # @param depth [Integer] limits the max depth of the hash. see {ClosureTree#hash_tree}
      # @return [Success({CustomField::Hierarchy::Item => Array, Hash})]
      def hashed_subtree(item:, depth:)
        if depth >= 0
          Success(item.hash_tree(limit_depth: depth + 1))
        else
          Success(item.hash_tree)
        end
      end

      # Checks if an item is a descendant of another node
      # @param item [CustomField::Hierarchy::Item] the item to be tested
      # @param parent [CustomField::Hierarchy::Item] the node to be checked against
      # @return [Success, Failure]
      def descendant_of?(item:, parent:)
        item.descendant_of?(parent) ? Success() : Failure()
      end

      private

      def create_root_item(custom_field)
        item = CustomField::Hierarchy::Item.create(custom_field: custom_field)
        return Failure(item.errors) if item.new_record?

        update_position_cache(item)
        Success(item)
      end

      def create_child_item(validation:, sort_order: nil)
        attributes = validation.to_h
        attributes[:sort_order] = sort_order - 1 if sort_order

        item = validation[:parent].children.create(**attributes)
        return Failure(item.errors) if item.new_record?

        update_position_cache(item.root)
        Success(item.reload)
      end

      def update_item_attributes(item:, attributes:)
        if item.update(label: attributes[:label], short: attributes[:short])
          Success(item)
        else
          Failure(item.errors)
        end
      end

      def update_item_order(item:, new_sort_order:)
        target_item = item.siblings.find_by(sort_order: new_sort_order)
        if target_item.present?
          target_item.prepend_sibling(item)
        else
          target_item = item.siblings.last
          target_item.append_sibling(item)
        end

        update_position_cache(item.root)
      end

      def update_position_cache(root)
        sql = <<-SQL.squish
          UPDATE hierarchical_items
          SET position_cache = subquery.position
          FROM (
            SELECT hi.id
                  , SUM((1 + COALESCE(anc.sort_order, 0)) *
                      POWER(count_max.total_descendants, count_max.max_gens - depths.generations)) AS position
            FROM hierarchical_items hi
                 INNER JOIN hierarchical_item_hierarchies hih ON hi.id = hih.descendant_id
                 JOIN hierarchical_item_hierarchies anc_h ON anc_h.descendant_id = hih.descendant_id
                 JOIN hierarchical_items anc ON anc.id = anc_h.ancestor_id
                 JOIN hierarchical_item_hierarchies depths ON depths.ancestor_id = #{root.id} AND depths.descendant_id = anc.id
               , (
                SELECT COUNT(1) AS total_descendants, MAX(generations) + 1 AS max_gens
                FROM hierarchical_items hi
                    INNER JOIN hierarchical_item_hierarchies hih ON hi.id = hih.ancestor_id
                WHERE ancestor_id = #{root.id}
                ) count_max
            WHERE hih.ancestor_id = #{root.id}
            GROUP BY hi.id) as subquery
          WHERE hierarchical_items.id = subquery.id;
        SQL

        OpenProject::Mutex.with_advisory_lock(CustomField::Hierarchy::Item, "position_update_anc_#{root.id}") do
          CustomField::Hierarchy::Item.connection.exec_update(sql)
        end
      end
    end
  end
end
