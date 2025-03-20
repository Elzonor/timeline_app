class Event < ApplicationRecord
	include DurationCalculator
	
	belongs_to :timeline, touch: true
	
	validates :name, presence: true
	validates :start_date, presence: true
	validates :event_type, presence: true, inclusion: { in: %w[open closed] }
	validate :end_date_after_start_date, if: -> { end_date.present? }
	validate :future_events_must_be_closed
	
	before_create :assign_color
	before_save :update_event_type
	
	# Scope per gli eventi aperti
	scope :ongoing, -> { where(event_type: 'open') }
	
	# Scope per gli eventi chiusi
	scope :completed, -> { where(event_type: 'closed') }
	
	# Scope per ordinare gli eventi dal più recente al meno recente
	scope :by_recency, -> {
		# Ordina prima per stato (aperti prima dei chiusi)
		# Poi per data di inizio discendente
		order(event_type: :desc, start_date: :desc)
	}
	
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
		# Non assegnare un colore se è già stato impostato manualmente
		return if self.color.present?
		
		# Imposta il colore predefinito a "#00A3D7"
		self.color = "#00A3D7"
	end

	def update_event_type
		self.event_type = end_date.present? ? 'closed' : 'open'
	end

	def future_events_must_be_closed
		if start_date&.future? && event_type == 'open'
			errors.add(:event_type, "gli eventi futuri devono avere una data di fine")
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
