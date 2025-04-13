class Timeline < ApplicationRecord
	include DurationCalculator
	
	has_many :events, dependent: :destroy
	has_one :preference, class_name: 'TimelinePreference', dependent: :destroy

	validates :name, presence: true, uniqueness: true

	def duration_details
		return nil if events.empty?
		
		# Troviamo le date estreme di tutti gli eventi
		start_date = events.minimum(:start_date)
		end_date = events.where.not(end_date: nil).maximum(:end_date)
		end_date = [end_date, Date.current].compact.max if events.where(end_date: nil).exists?

		calculate_duration(start_date, end_date, events)
	end

	def preferred_view_type
		preference&.view_type || 'weeks'
	end
end
