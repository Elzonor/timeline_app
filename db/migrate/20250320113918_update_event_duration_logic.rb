class UpdateEventDurationLogic < ActiveRecord::Migration[8.0]
  def up
    # Aggiorno i record esistenti con la nuova logica
    execute <<-SQL
      UPDATE events 
      SET event_duration = CASE 
        WHEN end_date IS NOT NULL AND start_date = end_date THEN '1-day'
        ELSE 'multi-day'
      END
    SQL
  end

  def down
    # Ripristino la logica precedente
    execute <<-SQL
      UPDATE events 
      SET event_duration = CASE 
        WHEN start_date = end_date OR end_date IS NULL THEN '1-day'
        ELSE 'multi-day'
      END
    SQL
  end
end
