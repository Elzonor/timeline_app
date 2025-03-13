class Event < ApplicationRecord
	include DurationCalculator
	
	belongs_to :timeline, touch: true
	
	validates :name, presence: true
	validates :start_date, presence: true
	validate :end_date_after_start_date, if: -> { end_date.present? }
	
	before_create :assign_color
	
	# Scope per gli eventi aperti
	scope :ongoing, -> { where(end_date: nil) }
	
	# Scope per gli eventi chiusi
	scope :completed, -> { where.not(end_date: nil) }
	
	# Scope per ordinare gli eventi dal più recente al meno recente
	scope :by_recency, -> {
		# Ordina prima per stato (aperti prima dei chiusi)
		# Poi per data di inizio discendente
		order(end_date: :asc, start_date: :desc)
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
