class MakeTimelineNamesUnique < ActiveRecord::Migration[7.1]
  def up
    # Troviamo tutti i nomi duplicati
    duplicates = Timeline.group(:name).having('COUNT(*) > 1').pluck(:name)
    
    duplicates.each do |name|
      # Per ogni nome duplicato, prendiamo tutte le timeline con quel nome
      timelines = Timeline.where(name: name).order(:created_at)
      
      # Saltiamo la prima timeline (mantiene il nome originale)
      timelines.each_with_index do |timeline, index|
        next if index == 0
        # Aggiungiamo un suffisso numerico al nome
        new_name = "#{name} (#{index + 1})"
        timeline.update_column(:name, new_name)
      end
    end
  end

  def down
    # Non possiamo ripristinare i nomi originali in modo sicuro
    raise ActiveRecord::IrreversibleMigration
  end
end
