# frozen_string_literal: true

# -- copyright
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
# ++
#

require "spec_helper"

RSpec.describe WorkPackages::Types::SubjectConfigurationController do
  let(:user) { create(:admin) }
  let(:wp_type) { create(:type) }

  current_user { user }

  context "when the user is not logged in" do
    let(:user) { User.anonymous }

    it "requires login" do
      put :update_subject_configuration, params: { id: wp_type.id }
      expect(response.status).to redirect_to signin_url(back_url: subject_configuration_type_url(wp_type))
    end
  end

  context "when the user is not an admin" do
    let(:user) { create(:user) }

    it "responds with forbidden" do
      put :update_subject_configuration, params: { id: wp_type.id }
      expect(response).to have_http_status :forbidden
    end
  end

  describe "PUT #update_subject_configuration" do
    before do
      service_double = instance_double(UpdateTypeService)
      allow(service_double)
        .to(receive(:call))
        .with({ patterns: expected_pattern_data })
        .and_yield(service_result)
      allow(UpdateTypeService).to receive(:new).and_return(service_double)

      put :update_subject_configuration,
          params: {
            id: wp_type.id,
            types_forms_subject_configuration_form_model: form_data
          }
    end

    context "if form data is invalid" do
      let(:form_data) { { subject_configuration: "generated", pattern: nil } }
      let(:expected_pattern_data) { { subject: { blueprint: "", enabled: true } } }
      let(:service_result) { ServiceResult.failure }

      it "renders the edit template" do
        expect(response).to have_http_status :unprocessable_entity
        expect(response).to render_template "types/edit"
      end
    end

    context "if form data is valid" do
      context "with generated subject configuration" do
        let(:form_data) { { subject_configuration: "generated", pattern: "Vacation - {{assignee}}" } }
        let(:expected_pattern_data) { { subject: { blueprint: "Vacation - {{assignee}}", enabled: true } } }
        let(:service_result) { ServiceResult.success }

        it "redirects to the current tab path" do
          expect(response).to redirect_to edit_tab_type_path(id: wp_type.id, tab: :subject_configuration)
        end
      end

      context "with manual subject configuration, but still persisted blueprint" do
        let(:form_data) { { subject_configuration: "manual", pattern: "Vacation - {{assignee}}" } }
        let(:expected_pattern_data) { { subject: { blueprint: "Vacation - {{assignee}}", enabled: false } } }
        let(:service_result) { ServiceResult.success }

        it "redirects to the current tab path" do
          expect(response).to redirect_to edit_tab_type_path(id: wp_type.id, tab: :subject_configuration)
        end
      end

      context "with manual subject configuration and no blueprint" do
        let(:form_data) { { subject_configuration: "manual", pattern: nil } }
        let(:expected_pattern_data) { {} }
        let(:service_result) { ServiceResult.success }

        it "redirects to the current tab path" do
          expect(response).to redirect_to edit_tab_type_path(id: wp_type.id, tab: :subject_configuration)
        end
      end
    end
  end
end
