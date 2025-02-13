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

require "spec_helper"

module TableHelpers::ColumnType
  RSpec.describe Properties do
    subject(:column_type) { described_class.new }

    def parsed_data(table)
      TableHelpers::TableParser.new.parse(table)
    end

    describe "empty" do
      it "stores nothing when empty" do
        work_package_data = parsed_data(<<~TABLE).first
          | properties |
          |            |
        TABLE
        expect(work_package_data[:relations]).to be_nil
        expect(work_package_data[:attributes]).to be_empty

        work_package_data = parsed_data(<<~TABLE).first
          | properties
          |
        TABLE
        expect(work_package_data[:relations]).to be_nil
        expect(work_package_data[:attributes]).to be_empty
      end
    end

    describe "follows <predecessor> [with lag <nb_days>]" do
      it "stores follows relations in work_package_data" do
        work_package_data = parsed_data(<<~TABLE).first
          | properties              |
          | follows main with lag 3 |
        TABLE
        expect(work_package_data[:relations])
          .to eq([{ raw: "follows main with lag 3", type: :follows, predecessor: "main", lag: 3 }])
      end

      it "has a default lag of 0 days when not specified" do
        work_package_data = parsed_data(<<~TABLE).first
          | properties   |
          | follows main |
        TABLE
        expect(work_package_data[:relations])
          .to eq([{ raw: "follows main", type: :follows, predecessor: "main", lag: 0 }])
      end

      it "can store multiple relations" do
        work_package_data = parsed_data(<<~TABLE).first
          | properties               |
          | follows wp1, follows wp2 |
        TABLE
        expect(work_package_data[:relations])
          .to eq([
                   { raw: "follows wp1", type: :follows, predecessor: "wp1", lag: 0 },
                   { raw: "follows wp2", type: :follows, predecessor: "wp2", lag: 0 }
                 ])
      end
    end
  end
end
