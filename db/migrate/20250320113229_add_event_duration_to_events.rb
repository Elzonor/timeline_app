class AddEventDurationToEvents < ActiveRecord::Migration[8.0]
  def up
    add_column :events, :event_duration, :string, default: '1-day', null: false
    add_index :events, :event_duration
    
    # Aggiorno i record esistenti
    execute <<-SQL
      UPDATE events 
      SET event_duration = CASE 
        WHEN start_date = end_date OR end_date IS NULL THEN '1-day'
        ELSE 'multi-day'
      END
    SQL
  end

  def down
    remove_column :events, :event_duration
  end
end
