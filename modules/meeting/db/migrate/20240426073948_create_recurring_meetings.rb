class CreateRecurringMeetings < ActiveRecord::Migration[7.1]
  def change
    create_table :recurring_meetings do |t|
      t.datetime :start_time
      t.date :end_date, null: true
      t.text :title
      t.integer :frequency, default: 0, null: false
      t.integer :end_after, default: 0, null: false
      t.integer :iterations, null: true
      t.belongs_to :project, foreign_key: true, index: true
      t.belongs_to :author, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_reference :meetings, :recurring_meeting, index: true
    add_column :meetings, :template, :boolean, default: false, null: false
  end
end
