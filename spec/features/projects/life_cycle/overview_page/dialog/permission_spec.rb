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
require_relative "../shared_context"

RSpec.describe "Edit project stages and gates on project overview page", :js, with_flag: { stages_and_gates: true } do
  include_context "with seeded projects and stages and gates"
  shared_let(:user) { create(:user) }
  let(:overview_page) { Pages::Projects::Show.new(project) }
  let(:permissions) { [] }

  current_user { user }

  before do
    mock_permissions_for(user) do |mock|
      mock.allow_in_project(*permissions, project:) # any project
    end
    overview_page.visit_page
  end

  describe "with insufficient View Stages and Gates permissions" do
    let(:permissions) { %i[view_project] }

    it "does not show the attributes sidebar" do
      overview_page.expect_no_visible_sidebar
    end
  end

  describe "with sufficient View Stages and Gates permissions" do
    let(:permissions) { %i[view_project view_project_stages_and_gates] }

    it "shows the attributes sidebar" do
      overview_page.within_life_cycles_sidebar do
        expect(page).to have_text("Project lifecycle")
      end
    end
  end

  describe "with Edit project permissions" do
    let(:permissions) { %i[view_project view_project_stages_and_gates edit_project] }

    it "does not show the edit buttons" do
      overview_page.within_life_cycles_sidebar do
        expect(page).to have_no_css("[data-test-selector='project-life-cycles-edit-button']")
      end
    end
  end

  describe "with sufficient Edit Stages and Gates permissions" do
    let(:permissions) { %i[view_project view_project_stages_and_gates edit_project edit_project_stages_and_gates] }

    it "shows the edit buttons" do
      overview_page.within_life_cycles_sidebar do
        expect(page).to have_css("[data-test-selector='project-life-cycles-edit-button']")
      end
    end
  end
end
