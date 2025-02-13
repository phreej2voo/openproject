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

RSpec.describe Queries::Projects::Orders::LifeCycleStepOrder do
  describe ".key" do
    it "matches key in correct format for life cycles" do
      expect(described_class.key).to match("lcsd_42")
    end

    it "doesn't match non numerical id" do
      expect(described_class.key).not_to match("lcsd_lcsd")
    end

    it "doesn't match with prefix" do
      expect(described_class.key).not_to match("xlcsd_42")
    end

    it "doesn't match with suffix" do
      expect(described_class.key).not_to match("lcsd_42x")
    end
  end

  describe "#available?" do
    let(:instance) { described_class.new("lcsd_#{life_cycle_def.id}") }

    let(:permissions) { %i(view_project_stages_and_gates) }
    let(:project) { create(:project) }
    let(:user) do
      create(:user, member_with_permissions: {
               project => permissions
             })
    end

    current_user { user }

    context "without feature flag set" do
      let!(:life_cycle_def) { create(:project_stage_definition) }

      it "does not allow to sort by it" do
        expect(instance).not_to be_available
      end
    end

    context "with feature flag set", with_flag: { stages_and_gates: true } do
      context "for a stage definition" do
        let!(:life_cycle_def) { create(:project_stage_definition) }

        it "allows to sort by it" do
          expect(instance).to be_available
        end
      end

      context "for a gate definition" do
        let!(:life_cycle_def) { create(:project_gate_definition) }

        it "allows to sort by it" do
          expect(instance).to be_available
        end
      end

      context "without permission in any project" do
        let!(:life_cycle_def) { create(:project_gate_definition) }
        let(:permissions) { [] }

        it "is not available" do
          expect(instance).not_to be_available
        end
      end
    end
  end

  describe "#life_cycle_step_definition" do
    let(:instance) { described_class.new(name) }
    let(:name) { "lcsd_42" }
    let(:id) { 42 }

    before do
      allow(Project::LifeCycleStepDefinition).to receive(:find_by).with(id: id.to_s).and_return(step_definition)
    end

    context "when life cycle definition exists" do
      let(:step_definition) { instance_double(Project::LifeCycleStepDefinition) }

      it "returns the life cycle definition" do
        expect(instance.life_cycle_step_definition).to eq(step_definition)
      end

      it "memoizes the life cycle definition" do
        2.times { instance.life_cycle_step_definition }

        expect(Project::LifeCycleStepDefinition).to have_received(:find_by).once
      end
    end

    context "when life cycle definition doesn't exist" do
      let(:step_definition) { nil }

      it "returns the life cycle" do
        expect(instance.life_cycle_step_definition).to be_nil
      end

      it "memoizes the life cycle" do
        2.times { instance.life_cycle_step_definition }

        expect(Project::LifeCycleStepDefinition).to have_received(:find_by).once
      end
    end
  end
end
