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
require_module_spec_helper

RSpec.describe "API v3 storage folders", :webmock, content_type: :json do
  include API::V3::Utilities::PathHelper
  include StorageServerHelpers

  let(:permissions) { %i(view_work_packages view_file_links manage_file_links) }
  let(:project) { create(:project) }

  let(:current_user) do
    create(:user, member_with_permissions: { project => permissions })
  end

  let(:oauth_application) { create(:oauth_application) }
  let(:storage) { create(:nextcloud_storage_configured, creator: current_user, oauth_application:) }
  let(:oauth_token) { create(:oauth_client_token, user: current_user, oauth_client: storage.oauth_client) }
  let(:project_storage) { create(:project_storage, project:, storage:) }

  subject(:last_response) { post(path, body) }

  before do
    oauth_application
    project_storage
    login_as current_user
  end

  describe "POST /api/v3/storages/:storage_id/folders" do
    let(:path) { api_v3_paths.storage_folders(storage.id) }
    let(:body) { { parent_id: file_info.id, name: folder_name }.to_json }
    let(:folder_name) { "TestFolder" }

    let(:response) do
      Storages::StorageFile.new(
        id: 1,
        name: folder_name,
        size: 128,
        mime_type: "application/x-op-directory",
        created_at: DateTime.now,
        last_modified_at: DateTime.now,
        created_by_name: "Obi-Wan Kenobi",
        last_modified_by_name: "Obi-Wan Kenobi",
        location: "/",
        permissions: %i[readable]
      )
    end

    let(:file_info) do
      Storages::StorageFileInfo.new(
        status: "OK",
        status_code: 200,
        id: SecureRandom.hex,
        name: "/",
        location: "/"
      )
    end

    before do
      file_info_mock = class_double(Storages::Peripherals::StorageInteraction::Nextcloud::FileInfoQuery)
      allow(file_info_mock).to receive(:call).with(
        storage: storage,
        auth_strategy: instance_of(Storages::Peripherals::StorageInteraction::AuthenticationStrategies::Strategy),
        file_id: file_info.id
      ).and_return(ServiceResult.success(result: file_info))
      Storages::Peripherals::Registry.stub("nextcloud.queries.file_info", file_info_mock)
    end

    context "with successful response" do
      subject { last_response.body }

      before do
        create_folder_mock = class_double(Storages::Peripherals::StorageInteraction::Nextcloud::CreateFolderCommand)
        allow(create_folder_mock).to receive(:call).with(
          storage: storage,
          auth_strategy: instance_of(Storages::Peripherals::StorageInteraction::AuthenticationStrategies::Strategy),
          folder_name:,
          parent_location: instance_of(Storages::Peripherals::ParentFolder)
        ).and_return(ServiceResult.success(result: response))
        Storages::Peripherals::Registry.stub("nextcloud.commands.create_folder", create_folder_mock)
      end

      it "responds with appropriate JSON" do
        expect(subject).to be_json_eql(response.id.to_json).at_path("id")
        expect(subject).to be_json_eql(response.name.to_json).at_path("name")
        expect(subject).to be_json_eql(response.permissions.to_json).at_path("permissions")
      end
    end

    context "with query failed" do
      before do
        create_folder_mock = class_double(Storages::Peripherals::StorageInteraction::Nextcloud::CreateFolderCommand)
        allow(create_folder_mock).to receive(:call).with(
          storage: storage,
          auth_strategy: instance_of(Storages::Peripherals::StorageInteraction::AuthenticationStrategies::Strategy),
          folder_name:,
          parent_location: instance_of(Storages::Peripherals::ParentFolder)
        ).and_return(ServiceResult.failure(result: error, errors: Storages::StorageError.new(code: error)))
        Storages::Peripherals::Registry.stub("nextcloud.commands.create_folder", create_folder_mock)
      end

      context "with authorization failure" do
        let(:error) { :unauthorized }

        it { expect(last_response).to have_http_status(:internal_server_error) }
      end

      context "with internal error" do
        let(:error) { :error }

        it { expect(last_response).to have_http_status(:internal_server_error) }
      end
    end
  end
end
