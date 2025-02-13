class AddIntervalToRecurringMeeting < ActiveRecord::Migration[7.1]
  def change
    add_column :recurring_meetings, :interval, :integer,
               default: 1, null: false
  end
end
