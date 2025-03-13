class AddIndicesToEvents < ActiveRecord::Migration[8.0]
  def change
    add_index :events, :timeline_id
    add_index :events, :start_date
    add_index :events, :end_date
  end
end
