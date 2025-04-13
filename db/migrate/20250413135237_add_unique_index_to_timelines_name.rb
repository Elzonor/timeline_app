class AddUniqueIndexToTimelinesName < ActiveRecord::Migration[7.1]
  def change
    add_index :timelines, :name, unique: true
  end
end
