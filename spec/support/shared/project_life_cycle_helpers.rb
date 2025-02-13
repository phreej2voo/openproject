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

RSpec.shared_examples_for "a Project::LifeCycleStepDefinition event" do
  it "inherits from LifeCycleStepDefinition" do
    expect(described_class).to be < Project::LifeCycleStepDefinition
  end

  describe "associations" do
    it { is_expected.to have_many(:life_cycle_steps).inverse_of(:definition).dependent(:destroy) }
    it { is_expected.to have_many(:projects).through(:life_cycle_steps) }
    it { is_expected.to belong_to(:color).required }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }

    it "is invalid if type is not Project::StageDefinition or Project::GateDefinition" do
      life_cycle = described_class.new
      life_cycle.type = "InvalidType"
      expect(life_cycle).not_to be_valid
      expect(life_cycle.errors[:type])
        .to include("must be either Project::StageDefinition or Project::GateDefinition")
    end
  end
end

RSpec.shared_examples_for "a Project::LifeCycleStep event" do
  it "inherits from Project::LifeCycleStep" do
    expect(described_class).to be < Project::LifeCycleStep
  end

  describe "associations" do
    it { is_expected.to belong_to(:project).required }
    it { is_expected.to belong_to(:definition).required }
    it { is_expected.to have_many(:work_packages) }
  end

  describe "validations" do
    it "is invalid if type is not Project::Stage or Project::Gate" do
      life_cycle = described_class.new
      life_cycle.type = "InvalidType"
      expect(life_cycle).not_to be_valid
      expect(life_cycle.errors[:type]).to include("must be either Project::Stage or Project::Gate")
    end
  end
end
