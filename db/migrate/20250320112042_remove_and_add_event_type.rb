class RemoveAndAddEventType < ActiveRecord::Migration[8.0]
  def up
    # Rimuovo la colonna se esiste
    remove_column :events, :event_type if column_exists?(:events, :event_type)
    
    # Aggiungo la nuova colonna
    add_column :events, :event_type, :string, default: 'open', null: false
    add_index :events, :event_type
    
    # Aggiorno i record esistenti
    execute <<-SQL
      UPDATE events 
      SET event_type = CASE 
        WHEN end_date IS NOT NULL THEN 'closed'
        ELSE 'open'
      END
    SQL
  end

  def down
    remove_column :events, :event_type
  end
end
