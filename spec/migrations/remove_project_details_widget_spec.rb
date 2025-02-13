# -- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2010-2024 the OpenProject GmbH
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
# ++

require "spec_helper"
require Rails.root.join("db/migrate/20241025072902_remove_project_details_widget.rb")

RSpec.describe RemoveProjectDetailsWidget, type: :model do
  subject do
    ActiveRecord::Migration.suppress_messages do
      described_class
        .new
        .tap { _1.migrate(:up) }
    end
  end

  let!(:overview) do
    create(:overview) do |o|
      create(:grid_widget, grid: o, identifier: "widget_a", start_row: 1, end_row: 2, start_column: 1, end_column: 2)
      create(:grid_widget, grid: o, identifier: "widget_b", start_row: 1, end_row: 2, start_column: 2, end_column: 3)
      create(:grid_widget, grid: o, identifier: "project_details", start_row: 2, end_row: 3, start_column: 1, end_column: 2)
      create(:grid_widget, grid: o, identifier: "widget_c", start_row: 2, end_row: 3, start_column: 2, end_column: 3)
      create(:grid_widget, grid: o, identifier: "widget_d", start_row: 3, end_row: 4, start_column: 1, end_column: 2)
      create(:grid_widget, grid: o, identifier: "widget_1", start_row: 4, end_row: 4, start_column: 2, end_column: 3)
    end
  end

  it "removes only the project_details widget", :aggregate_failures do
    subject

    expect(Grids::Widget.where(identifier: "project_details")).not_to exist
    expect(Grids::Widget.where(identifier: "widget_a", start_row: 1, end_row: 2, start_column: 1, end_column: 2)).to exist
    expect(Grids::Widget.where(identifier: "widget_b", start_row: 1, end_row: 2, start_column: 2, end_column: 3)).to exist
    expect(Grids::Widget.where(identifier: "widget_c", start_row: 2, end_row: 3, start_column: 2, end_column: 3)).to exist
    expect(Grids::Widget.where(identifier: "widget_d", start_row: 3, end_row: 4, start_column: 1, end_column: 2)).to exist
    expect(Grids::Widget.where(identifier: "widget_1", start_row: 4, end_row: 4, start_column: 2, end_column: 3)).to exist
  end
end
