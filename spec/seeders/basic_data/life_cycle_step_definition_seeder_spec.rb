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

RSpec.describe BasicData::LifeCycleStepDefinitionSeeder do
  include_context "with basic seed data"
  subject(:seeder) { described_class.new(seed_data) }

  let(:seed_data) { basic_seed_data.merge(Source::SeedData.new(data_hash)) }

  before do
    seeder.seed!
  end

  context "with some life cycles defined" do
    let(:data_hash) do
      YAML.load <<~SEEDING_DATA_YAML
        life_cycles:
        - reference: :default_life_cycle_initiating
          name: Initiating
          type: Project::StageDefinition
          color_name: :default_color_pm2_orange
        - reference: :default_life_cycle_ready_for_executing
          name: Ready for Executing
          type: Project::GateDefinition
          color_name: :default_color_pm2_purple
        - reference: :default_life_cycle_planning
          name: Planning
          type: Project::StageDefinition
          color_name: :default_color_pm2_red
        - reference: :default_life_cycle_executing
          name: Executing
          type: Project::StageDefinition
          color_name: :default_color_pm2_magenta
        - reference: :default_life_cycle_closing
          name: Closing
          type: Project::StageDefinition
          color_name: :default_color_pm2_green_yellow
      SEEDING_DATA_YAML
    end

    it "creates the corresponding life cycles with the given attributes" do
      expect(Project::LifeCycleStepDefinition.count).to eq(5)
      expect(Project::StageDefinition.find_by(name: "Initiating")).to have_attributes(
        color: have_attributes(name: "PM2 Orange")
      )
      expect(Project::GateDefinition.find_by(name: "Ready for Executing")).to have_attributes(
        color: have_attributes(name: "PM2 Purple")
      )
      expect(Project::StageDefinition.find_by(name: "Planning")).to have_attributes(
        color: have_attributes(name: "PM2 Red")
      )
      expect(Project::StageDefinition.find_by(name: "Executing")).to have_attributes(
        color: have_attributes(name: "PM2 Magenta")
      )
      expect(Project::StageDefinition.find_by(name: "Closing")).to have_attributes(
        color: have_attributes(name: "PM2 Green Yellow")
      )
    end

    it "references the life cycles in the seed data" do
      Project::LifeCycleStepDefinition.find_each do |expected_stage|
        reference = :"default_life_cycle_#{expected_stage.name.downcase.gsub(/\s+/, '_')}"
        expect(seed_data.find_reference(reference)).to eq(expected_stage)
      end
    end

    context "when seeding a second time" do
      subject(:second_seeder) { described_class.new(second_seed_data) }

      let(:second_seed_data) { basic_seed_data.merge(Source::SeedData.new(data_hash)) }

      before do
        second_seeder.seed!
      end

      it "registers existing matching life cycles as references in the seed data" do
        # using the first seed data as the expected value
        expect(second_seed_data.find_reference(:default_life_cycle_initiating))
          .to eq(seed_data.find_reference(:default_life_cycle_initiating))
        expect(second_seed_data.find_reference(:default_life_cycle_ready_for_executing))
          .to eq(seed_data.find_reference(:default_life_cycle_ready_for_executing))
        expect(second_seed_data.find_reference(:default_life_cycle_planning))
          .to eq(seed_data.find_reference(:default_life_cycle_planning))
        expect(second_seed_data.find_reference(:default_life_cycle_executing))
          .to eq(seed_data.find_reference(:default_life_cycle_executing))
        expect(second_seed_data.find_reference(:default_life_cycle_closing))
          .to eq(seed_data.find_reference(:default_life_cycle_closing))
      end
    end
  end

  context "without life cycles defined" do
    let(:data_hash) do
      YAML.load <<~SEEDING_DATA_YAML
        nothing here: ''
      SEEDING_DATA_YAML
    end

    it "creates no life cycles" do
      expect(Project::LifeCycleStepDefinition.count).to eq(0)
    end
  end
end
