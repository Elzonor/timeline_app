class AddEventTypeToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :event_type, :string, default: 'open', null: false
    add_index :events, :event_type
  end
end
