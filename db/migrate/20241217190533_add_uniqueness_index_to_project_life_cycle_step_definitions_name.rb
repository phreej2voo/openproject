class AddUniquenessIndexToProjectLifeCycleStepDefinitionsName < ActiveRecord::Migration[7.1]
  def change
    add_index :project_life_cycle_step_definitions, :name, unique: true
  end
end
