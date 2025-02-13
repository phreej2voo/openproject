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

RSpec.describe ProjectCustomFieldProjectMappings::BulkUpdateService do
  let!(:project) { create(:project) }
  let!(:section_with_invisible_fields) { create(:project_custom_field_section, name: "Section with invisible fields") }

  let!(:visible_project_custom_field) do
    create(:project_custom_field,
           name: "Visible field",
           admin_only: false,
           project_custom_field_section: section_with_invisible_fields)
  end

  let!(:visible_required_project_custom_field) do
    create(:project_custom_field,
           name: "Visible required field",
           admin_only: false,
           is_required: true,
           project_custom_field_section: section_with_invisible_fields)
  end

  let!(:invisible_project_custom_field) do
    create(:project_custom_field,
           name: "Admin only field",
           admin_only: true,
           project_custom_field_section: section_with_invisible_fields)
  end

  let(:instance) { described_class.new(user:, project:, project_custom_field_section: section_with_invisible_fields) }

  context "with admin permissions" do
    let(:user) { create(:admin) }

    it "bulk enables/disables all (non-required) fields of the section, including invisible ones" do
      expect(project.project_custom_fields).to contain_exactly(
        visible_required_project_custom_field
      )

      expect(instance.call(action: :enable)).to be_success

      expect(project.reload.project_custom_fields).to contain_exactly(
        visible_required_project_custom_field, visible_project_custom_field, invisible_project_custom_field
      )

      expect(instance.call(action: :disable)).to be_success

      # required fields cannot be disabled, even not by admins
      expect(project.reload.project_custom_fields).to contain_exactly(
        visible_required_project_custom_field
      )
    end
  end

  context "with non-admin but sufficient permissions" do
    let(:user) do
      create(:user,
             firstname: "Project",
             lastname: "Admin",
             member_with_permissions: {
               project => %w[
                 view_work_packages
                 edit_project
                 select_project_custom_fields
               ]
             })
    end

    it "bulk enables/disables all fields of the section, excluding invisible ones" do
      expect(project.project_custom_fields).to contain_exactly(
        visible_required_project_custom_field
      )

      expect(instance.call(action: :enable)).to be_success

      expect(project.reload.project_custom_fields).to contain_exactly(
        visible_required_project_custom_field, visible_project_custom_field
      )

      project.project_custom_fields << invisible_project_custom_field

      expect(instance.call(action: :disable)).to be_success

      # required fields cannot be disabled, invisible fields are not affected by non-admins
      expect(project.reload.project_custom_fields).to contain_exactly(
        visible_required_project_custom_field, invisible_project_custom_field
      )
    end
  end

  context "with insufficient permissions" do
    let(:user) do
      create(:user,
             firstname: "Project",
             lastname: "Editor",
             member_with_permissions: {
               project => %w[
                 view_work_packages
                 edit_project
               ]
             })
    end

    it "cannot bulk enable/disable project custom fields" do
      expect(project.project_custom_fields).to contain_exactly(
        visible_required_project_custom_field
      )

      expect(instance.call(action: :enable)).to be_failure

      expect(project.reload.project_custom_fields).to contain_exactly(
        visible_required_project_custom_field
      )

      expect(instance.call(action: :disable)).to be_failure
    end
  end
end
