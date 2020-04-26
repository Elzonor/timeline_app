class JoinTimelineAndEvents < ActiveRecord::Migration[5.2]
  def change
		add_column :timelines, :event_id, :integer
		add_column :events, :timeline_id, :integer
  end
end
