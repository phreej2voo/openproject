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

module Storages
  class CreateFolderService < BaseService
    using Peripherals::ServiceResultRefinements

    def self.call(storage:, user:, name:, parent_id:)
      new.call(storage:, user:, name:, parent_id:)
    end

    def call(storage:, user:, name:, parent_id:)
      auth_strategy = Peripherals::Registry.resolve("#{storage}.authentication.user_bound").call(user: user)

      Peripherals::Registry
        .resolve("#{storage}.commands.create_folder")
        .call(
          storage:,
          auth_strategy:,
          folder_name: name,
          parent_location: parent_path(parent_id, storage, user)
        )
    end

    private

    def parent_path(parent_id, storage, user)
      case storage.short_provider_type
      when "nextcloud"
        location_from_file_info(parent_id, storage, user)
      when "one_drive"
        Peripherals::ParentFolder.new(parent_id)
      else
        raise "Unknown Storage Type"
      end
    end

    def location_from_file_info(parent_id, storage, user)
      StorageFileService
        .call(storage: storage, user: user, file_id: parent_id)
        .match(
          on_success: lambda { |folder_info|
            path = URI.decode_uri_component(folder_info.location)
            Peripherals::ParentFolder.new(path)
          },
          on_failure: ->(error) { raise error }
        )
    end
  end
end
