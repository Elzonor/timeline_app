class Event < ApplicationRecord
	include DurationCalculator
	
	belongs_to :timeline, touch: true
	
	validates :start_date, presence: true
	validate :end_date_after_start_date, if: -> { end_date.present? }
	
	before_create :assign_color
	
	def duration
		return nil unless start_date
		end_date_to_use = end_date || Date.current
		(end_date_to_use.to_date - start_date.to_date).to_i
	end

	def duration_details
		return nil unless start_date
		calculate_duration(start_date, end_date)
	end
	
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
			if match = last_event.color&.match(/hsl\((\d+),/)
				last_hue = match[1].to_i
				new_hue = (last_hue + 125) % 360
				self.color = "hsl(#{new_hue}, 60%, 50%)"
			else
				self.color = "hsl(140, 60%, 50%)"
			end
		end
	end

	def count_weeks
		start_week = start_date.beginning_of_week
		end_week = (end_date || Date.current).end_of_week
		weeks = []
		current = start_week
		
		while current <= end_week
			weeks << current if date_range_includes_day?(current)
			current += 1.week
		end
		weeks.uniq.count
	end

	def count_months
		start_month = start_date.beginning_of_month
		end_month = (end_date || Date.current).end_of_month
		months = []
		current = start_month
		
		while current <= end_month
			months << current if date_range_includes_day?(current)
			current += 1.month
		end
		months.uniq.count
	end

	def date_range_includes_day?(day)
		range_end = end_date || Date.current
		(start_date..range_end).cover?(day)
	end
end
