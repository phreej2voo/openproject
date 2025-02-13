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

require "rails_helper"
require "support/shared/project_life_cycle_helpers"

RSpec.describe Project::Stage do
  it_behaves_like "a Project::LifeCycleStep event"

  describe "validations" do
    it { is_expected.to validate_inclusion_of(:type).in_array(["Project::Stage"]).with_message(:must_be_a_stage) }

    it "is valid when `start_date` and `end_date` are present" do
      valid_stage = build(:project_stage)
      expect(valid_stage).to be_valid
    end
  end

  describe "#not_set?" do
    it "returns true if start_date or end_date is blank" do
      expect(subject.not_set?).to be(true)
    end

    it "returns false if both start_date and end_date are present" do
      subject.start_date = Time.zone.today
      subject.end_date = Date.tomorrow
      expect(subject.not_set?).to be(false)
    end
  end

  describe "#date_range=" do
    it "splits a valid date range string into start_date and end_date" do
      subject.date_range = "2024-11-26 - 2024-11-27"
      expect(subject.start_date).to eq(Date.parse("2024-11-26"))
      expect(subject.end_date).to eq(Date.parse("2024-11-27"))
    end

    it "sets end_date to start_date if a single date is provided" do
      subject.date_range = "2024-11-26"
      expect(subject.start_date).to eq(Date.parse("2024-11-26"))
      expect(subject.end_date).to eq(Date.parse("2024-11-26"))
    end
  end

  describe "#validate_date_range" do
    it "is valid when both dates are blank" do
      stage = build(:project_stage, start_date: nil, end_date: nil)
      expect(stage).to be_valid
    end

    it "adds error if start_date is blank" do
      subject.end_date = Time.zone.today
      expect(subject).not_to be_valid
      expect(subject.errors.symbols_for(:date_range)).to include(:incomplete)
    end

    it "adds error if end_date is blank" do
      subject.start_date = Time.zone.today
      expect(subject).not_to be_valid
      expect(subject.errors.symbols_for(:date_range)).to include(:incomplete)
    end

    it "adds error if start_date is after end_date" do
      subject.start_date = Date.tomorrow
      subject.end_date = Time.zone.today
      expect(subject).not_to be_valid
      expect(subject.errors.symbols_for(:date_range)).to include(:start_date_must_be_before_end_date)
    end

    it "does not add errors if start_date is before or equal to end_date" do
      subject.start_date = Time.zone.today
      subject.end_date = Time.zone.today
      expect(subject).not_to be_valid
      expect(subject.errors[:date_range]).to be_empty
    end

    it "is invalid if type and class name do not match" do
      subject.type = "Project::Gate"
      expect(subject).not_to be_valid
      expect(subject.errors.symbols_for(:type)).to include(:type_and_class_name_mismatch)
    end
  end

  describe "#working_days_count" do
    it "returns nil if not_set? is true" do
      allow(Day).to receive(:working)

      subject.start_date = nil
      subject.end_date = nil

      expect(subject.working_days_count).to be_nil
      expect(Day).not_to have_received(:working)
    end

    it "returns the correct number of days if start_date and end_date are the same" do
      subject.start_date = Time.zone.today
      subject.end_date = Time.zone.today
      expect(subject.working_days_count).to eq(1)
    end

    it "returns the correct number of days for a valid date range" do
      subject.start_date = Date.parse("2024-11-25")
      subject.end_date = Date.parse("2024-11-27")
      expect(subject.working_days_count).to eq(3)
    end

    it "calls the Day.working.from_range method with the right arguments" do
      subject.start_date = Date.parse("2024-11-25")
      subject.end_date = Date.parse("2024-11-27")

      allow(Day).to receive(:working).and_return(Day)
      allow(Day).to receive(:from_range)
                .with(from: subject.start_date, to: subject.end_date)
                .and_return([])

      expect(subject.working_days_count).to eq(0)

      expect(Day).to have_received(:working).with(no_args)
      expect(Day).to have_received(:from_range).with(from: subject.start_date, to: subject.end_date)
    end
  end
end
