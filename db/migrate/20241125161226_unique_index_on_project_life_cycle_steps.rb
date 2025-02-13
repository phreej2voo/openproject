class UniqueIndexOnProjectLifeCycleSteps < ActiveRecord::Migration[7.1]
  def change
    add_index :project_life_cycle_steps,
              %i[project_id definition_id],
              unique: true
  end
end
