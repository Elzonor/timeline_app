class MakeTimelineNamesCaseInsensitiveUnique < ActiveRecord::Migration[7.1]
  def up
    # Troviamo tutti i nomi che sono duplicati quando convertiti in minuscolo
    duplicates = Timeline.group('LOWER(name)').having('COUNT(*) > 1').pluck(Arel.sql('LOWER(name)'))
    
    duplicates.each do |lower_name|
      # Per ogni nome duplicato, prendiamo tutte le timeline con quel nome (case-insensitive)
      timelines = Timeline.where('LOWER(name) = ?', lower_name).order(:created_at)
      
      # Saltiamo la prima timeline (mantiene il nome originale)
      timelines.each_with_index do |timeline, index|
        next if index == 0
        # Aggiungiamo un suffisso numerico al nome originale
        new_name = "#{timeline.name} (#{index + 1})"
        timeline.update_column(:name, new_name)
      end
    end
  end

  def down
    # Non possiamo ripristinare i nomi originali in modo sicuro
    raise ActiveRecord::IrreversibleMigration
  end
end
