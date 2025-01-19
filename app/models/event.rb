class Event < ApplicationRecord
	belongs_to :timeline, touch: true
	
	validates :start_date, presence: true
	validate :end_date_after_start_date, if: -> { end_date.present? }
	
	before_create :assign_color
	
	private
	
	def end_date_after_start_date
		if end_date < start_date
			errors.add(:end_date, "deve essere successiva alla data di inizio")
		end
	end
	
	def assign_color
		last_event = timeline.events.order(created_at: :desc).first
		if last_event.nil?
			self.color = "hsl(140, 60%, 50%)" # Primo evento
		else
			last_hue = last_event.color.match(/hsl\((\d+),/)[1].to_i
			new_hue = (last_hue + 125) % 360
			self.color = "hsl(#{new_hue}, 60%, 50%)"
		end
	end
end
