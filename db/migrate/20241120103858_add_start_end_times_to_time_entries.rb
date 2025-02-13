class AddStartEndTimesToTimeEntries < ActiveRecord::Migration[7.1]
  def change
    change_table :time_entries, bulk: true do |t|
      t.integer :start_time, null: true
      t.integer :end_time, null: true
    end

    change_table :time_entry_journals, bulk: true do |t|
      t.integer :start_time, null: true
      t.integer :end_time, null: true
    end
  end
end
