class TimelinePreference < ApplicationRecord
  belongs_to :timeline

  validates :view_type, presence: true, inclusion: { in: %w[days weeks months years] }
  validates :timeline_id, presence: true, uniqueness: true
end 