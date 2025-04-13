class AddCaseInsensitiveIndexToTimelinesName20250413135650 < ActiveRecord::Migration[7.1]
  def up
    # Rimuovo l'indice esistente
    remove_index :timelines, :name if index_exists?(:timelines, :name)
    
    # Aggiungo l'indice case-insensitive
    execute <<-SQL
      CREATE UNIQUE INDEX index_timelines_on_name_case_insensitive 
      ON timelines (LOWER(name));
    SQL
  end

  def down
    # Rimuovo l'indice case-insensitive
    execute <<-SQL
      DROP INDEX IF EXISTS index_timelines_on_name_case_insensitive;
    SQL
    
    # Ripristino l'indice originale
    add_index :timelines, :name, unique: true
  end
end
