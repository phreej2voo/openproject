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

require "spec_helper"

RSpec.describe CustomFields::Hierarchy::HierarchicalItemService do
  let!(:custom_field) { create(:custom_field, field_format: "hierarchy", hierarchy_root: nil) }
  let!(:invalid_custom_field) { create(:custom_field, field_format: "text", hierarchy_root: nil) }

  let!(:root) { service.generate_root(custom_field).value! }
  let!(:luke) { service.insert_item(parent: root, label: "luke", short: "LS").value! }
  let!(:mara) { service.insert_item(parent: luke, label: "mara").value! }

  subject(:service) { described_class.new }

  describe "#generate_root" do
    context "with valid hierarchy root" do
      it "creates a root item successfully" do
        expect(service.generate_root(custom_field)).to be_success
      end
    end

    it "requires a custom field of type hierarchy" do
      result = service.generate_root(invalid_custom_field).failure

      expect(result.errors[:custom_field]).to eq(["must have field format 'hierarchy'"])
    end

    context "with persistence of hierarchy root fails" do
      it "fails to create a root item" do
        allow(CustomField::Hierarchy::Item)
          .to receive(:create)
                .and_return(instance_double(CustomField::Hierarchy::Item, new_record?: true, errors: "some errors"))

        result = service.generate_root(custom_field)
        expect(result).to be_failure
      end
    end
  end

  describe "#insert_item" do
    let(:label) { "Child Item" }
    let(:short) { "Short Description" }

    context "with valid parameters" do
      it "inserts an item successfully without short" do
        result = service.insert_item(parent: luke, label:)

        expect(result).to be_success
        expect(luke.reload.children.count).to eq(2)
      end

      it "inserts an item successfully with short" do
        result = service.insert_item(parent: root, label:, short:)
        expect(result).to be_success
      end

      it "insert an item into a specific sort_order" do
        leia = service.insert_item(parent: root, label: "leia").value!
        expect(root.reload.children).to contain_exactly(luke, leia)

        bob = service.insert_item(parent: root, label: "Bob", sort_order: 1).value!
        expect(root.reload.children).to contain_exactly(luke, bob, leia)
      end

      it "updates the position_cache" do
        leia = service.insert_item(parent: root, label: "leia").value!
        expect(root.reload.position_cache).to eq(64)

        service.insert_item(parent: root, label: "Bob", sort_order: 1).value!
        expect(leia.reload.position_cache).to eq(200)
      end
    end

    context "with invalid item" do
      it "fails to insert an item" do
        child = instance_double(CustomField::Hierarchy::Item, new_record?: true, errors: "some errors")
        allow(root.children).to receive(:create).and_return(child)

        result = service.insert_item(parent: root, label:, short:)
        expect(result).to be_failure
      end
    end
  end

  describe "#update_item" do
    context "with valid parameters" do
      it "updates the item with new attributes" do
        result = service.update_item(item: luke, label: "Luke Skywalker", short: "LS")
        expect(result).to be_success
      end
    end

    context "with invalid parameters" do
      let!(:leia) { service.insert_item(parent: root, label: "leia").value! }

      it "refuses to update the item with new attributes" do
        result = service.update_item(item: leia, label: "luke", short: "LS")
        expect(result).to be_failure

        errors = result.failure.errors
        expect(errors[:label]).to eq(["must be unique within the same hierarchy level."])
        expect(errors[:short]).to eq(["must be unique within the same hierarchy level."])
      end
    end
  end

  describe "#delete_branch" do
    context "with valid item to destroy" do
      it "deletes the entire branch" do
        result = service.delete_branch(item: luke)
        expect(result).to be_success
        expect(luke).to be_frozen
        expect(CustomField::Hierarchy::Item.count).to eq(1)
        expect(root.reload.children).to be_empty
      end

      it "updates the position_cache" do
        result = service.delete_branch(item: luke)

        expect(result).to be_success
        expect(root.reload.position_cache).to eq(27)
      end
    end

    context "with root item" do
      it "refuses to delete the item" do
        result = service.delete_branch(item: root)
        expect(result).to be_failure
      end
    end
  end

  describe "#get_branch" do
    context "with a non-root node" do
      it "returns all the ancestors to that item" do
        result = service.get_branch(item: mara)
        expect(result).to be_success

        ancestors = result.value!
        expect(ancestors.size).to eq(3)
        expect(ancestors).to contain_exactly(root, luke, mara)
        expect(ancestors.last).to eq(mara)
      end
    end

    context "with a root node" do
      it "returns a empty list" do
        result = service.get_branch(item: root)
        expect(result).to be_success
        expect(result.value!).to match_array(root)
      end
    end
  end

  describe "#get_descendants" do
    let!(:subitem) { service.insert_item(parent: mara, label: "Sub1").value! }
    let!(:subitem2) { service.insert_item(parent: mara, label: "sub two").value! }
    let!(:unrelated_subitem) { service.insert_item(parent: luke, label: "not related").value! }

    context "with a non-root node" do
      it "returns all the descendants to that item" do
        result = service.get_descendants(item: mara)
        expect(result).to be_success

        descendants = result.value!
        expect(descendants.size).to eq(3)
        expect(descendants).to contain_exactly(mara, subitem, subitem2)
      end
    end

    context "with a leaf node" do
      it "returns just the leaf node" do
        result = service.get_descendants(item: subitem2)
        expect(result).to be_success
        expect(result.value!).to match_array(subitem2)
      end
    end

    context "when does not include self" do
      it "returns all descendants not including the item passed" do
        result = service.get_descendants(item: mara, include_self: false)
        expect(result).to be_success

        descendants = result.value!
        expect(descendants.size).to eq(2)
        expect(descendants).to contain_exactly(subitem, subitem2)
      end
    end
  end

  describe "#move_item" do
    let(:lando) { service.insert_item(parent: root, label: "lando").value! }

    it "move the node to the new parent" do
      expect { service.move_item(item: mara, new_parent: lando) }.to change { mara.reload.ancestors.first }.to(lando)
    end

    it "all child nodes follow" do
      service.move_item(item: luke, new_parent: lando)

      expect(luke.reload.ancestors).to contain_exactly(root, lando)
      expect(mara.reload.ancestors).to contain_exactly(root, lando, luke)
    end

    it "updates the position_cache" do
      service.move_item(item: luke, new_parent: lando)

      preordered_descendants = root.reload.self_and_descendants_preordered.pluck(:label)
      expect(root.self_and_descendants.reorder(:position_cache).pluck(:label)).to eq(preordered_descendants)
    end
  end

  describe "#reorder_item" do
    let!(:lando) { service.insert_item(parent: root, label: "lando").value! }
    let!(:chewbacca) { service.insert_item(parent: root, label: "AWOOO").value! }

    it "reorders the item to the target position" do
      service.reorder_item(item: chewbacca, new_sort_order: 1)

      expect(luke.reload.sort_order).to eq(0)
      expect(chewbacca.reload.sort_order).to eq(1)
      expect(lando.reload.sort_order).to eq(2)
    end

    it "reorders the item even if sort order is a string" do
      service.reorder_item(item: chewbacca, new_sort_order: "1")

      expect(luke.reload.sort_order).to eq(0)
      expect(chewbacca.reload.sort_order).to eq(1)
      expect(lando.reload.sort_order).to eq(2)
    end

    it "reorders the item to the last position" do
      service.reorder_item(item: lando, new_sort_order: root.children.length)

      expect(luke.reload.sort_order).to eq(0)
      expect(chewbacca.reload.sort_order).to eq(1)
      expect(lando.reload.sort_order).to eq(2)
    end

    it "reorders the item to the first position" do
      service.reorder_item(item: chewbacca, new_sort_order: 0)

      expect(chewbacca.reload.sort_order).to eq(0)
      expect(luke.reload.sort_order).to eq(1)
      expect(lando.reload.sort_order).to eq(2)
    end

    it "does not reorder before first" do
      service.reorder_item(item: lando, new_sort_order: -10)

      expect(lando.reload.sort_order).to eq(0)
      expect(luke.reload.sort_order).to eq(1)
      expect(chewbacca.reload.sort_order).to eq(2)
    end

    it "does not reorder after last" do
      service.reorder_item(item: chewbacca, new_sort_order: 99)

      expect(luke.reload.sort_order).to eq(0)
      expect(lando.reload.sort_order).to eq(1)
      expect(chewbacca.reload.sort_order).to eq(2)
    end

    it "does not reorder when changing self" do
      service.reorder_item(item: lando, new_sort_order: lando.sort_order)

      expect(luke.reload.sort_order).to eq(0)
      expect(lando.reload.sort_order).to eq(1)
      expect(chewbacca.reload.sort_order).to eq(2)
    end

    it "updates the position_cache" do
      service.reorder_item(item: chewbacca, new_sort_order: 0)

      preordered_descendants = root.reload.self_and_descendants_preordered.pluck(:label)
      expect(root.self_and_descendants.reorder(:position_cache).pluck(:label)).to eq(preordered_descendants)
    end
  end

  describe "#hashed_subtree" do
    let!(:lando) { service.insert_item(parent: root, label: "lando").value! }
    let!(:chewbacca) { service.insert_item(parent: root, label: "AWOOO").value! }
    let!(:lowbacca) { service.insert_item(parent: chewbacca, label: "ARWWWW").value! }

    it "produces a hash version of the tree" do
      subtree = service.hashed_subtree(item: root, depth: -1)

      expect(subtree.value!).to be_a(Hash)
      expect(subtree.value![root].size).to eq(3)
      expect(subtree.value![root][lando]).to be_empty
      expect(subtree.value![root][chewbacca][lowbacca]).to be_empty
    end

    it "produces a hash version of a sub tree with limited depth" do
      subtree = service.hashed_subtree(item: chewbacca, depth: 0)

      expect(subtree.value!).to be_a(Hash)
      expect(subtree.value![chewbacca]).to be_empty
    end
  end
end
