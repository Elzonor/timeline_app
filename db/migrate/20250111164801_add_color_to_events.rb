class AddColorToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :color, :string
  end
end
