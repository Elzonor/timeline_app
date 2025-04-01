class CreateTimelinePreferences < ActiveRecord::Migration[7.1]
  def change
    create_table :timeline_preferences do |t|
      t.references :timeline, null: false, foreign_key: true, index: { unique: true }
      t.string :view_type, null: false, default: 'weeks'

      t.timestamps
    end
  end
end
