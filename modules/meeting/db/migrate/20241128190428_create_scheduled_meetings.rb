class CreateScheduledMeetings < ActiveRecord::Migration[7.1]
  def change
    create_table :scheduled_meetings do |t|
      t.belongs_to :recurring_meeting,
                   null: false,
                   foreign_key: { index: true, on_delete: :cascade }

      t.belongs_to :meeting,
                   null: true,
                   foreign_key: { index: true, unique: true, on_delete: :nullify }

      t.datetime :start_time, null: false
      t.boolean :cancelled, default: false, null: false

      t.timestamps
    end

    add_index :scheduled_meetings,
              %i[recurring_meeting_id start_time],
              unique: true
  end
end
