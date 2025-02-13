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

RSpec.describe Types::PatternResolver do
  let(:subject_pattern) { "ID Please: {{id}}" }

  shared_let(:work_package) { create(:work_package) }

  subject(:resolver) { described_class.new(subject_pattern) }

  it "resolves a pattern" do
    expect(subject.resolve(work_package)).to eq("ID Please: #{work_package.id}")
  end

  context "when the pattern has WorkPackage properties" do
    let(:subject_pattern) { "{{id}} | {{done_ratio}} | {{creation_date}}" }

    it "resolves the pattern" do
      expect(subject.resolve(work_package))
        .to eq("#{work_package.id} | NA | #{work_package.created_at.to_date.iso8601}")
    end
  end

  context "when the pattern has WorkPackage association attributes" do
    let(:subject_pattern) { "{{id}} | {{author}} | {{type}}" }

    it "resolves the pattern" do
      expect(subject.resolve(work_package))
        .to eq("#{work_package.id} | #{work_package.author.name} | #{work_package.type.name}")
    end
  end

  context "when the pattern has custom fields" do
    let(:custom_field) { create(:string_wp_custom_field) }
    let(:type) { create(:type, custom_fields: [custom_field]) }
    let(:project) { create(:project, types: [type], work_package_custom_fields: [custom_field]) }
    let(:project_custom_field) { create(:project_custom_field, projects: [project], field_format: "string") }

    let(:subject_pattern) do
      "{{project_custom_field_#{project_custom_field.id}}} A custom field value: {{custom_field_#{custom_field.id}}}"
    end

    let(:work_package) do
      create(:work_package, type:, project:, custom_values: { custom_field.id => "Important Information" })
    end

    before do
      project.public_send :"custom_field_#{project_custom_field.id}=", "PROSPEC"
      project.save
    end

    it "resolves the pattern" do
      User.current = SystemUser.first

      expect(subject.resolve(work_package)).to eq("PROSPEC A custom field value: Important Information")
    end
  end
end
