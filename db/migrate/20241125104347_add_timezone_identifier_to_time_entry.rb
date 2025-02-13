class AddTimezoneIdentifierToTimeEntry < ActiveRecord::Migration[7.1]
  def change
    change_table :time_entries, bulk: true do |t|
      t.string :time_zone, null: true
      t.remove :end_time, type: :integer
    end

    change_table :time_entry_journals, bulk: true do |t|
      t.string :time_zone, null: true
      t.remove :end_time, type: :integer
    end
  end
end
