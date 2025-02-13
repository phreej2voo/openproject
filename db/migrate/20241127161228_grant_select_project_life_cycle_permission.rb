require_relative "migration_utils/permission_adder"

class GrantSelectProjectLifeCyclePermission < ActiveRecord::Migration[7.1]
  def up
    ::Migration::MigrationUtils::PermissionAdder.add(:edit_project, :select_project_life_cycle)
  end
end
