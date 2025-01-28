class Timeline < ApplicationRecord
	has_many :events, dependent: :destroy

	validates :name, presence: true

	def duration_details
		return nil if events.empty?
		
		# Inizializziamo i Set per settimane e mesi
		weeks = Set.new
		months = Set.new
		
		# Per ogni evento, aggiungiamo tutte le date dal suo inizio alla sua fine
		events.each do |event|
			end_date = event.end_date || Date.current
			current_date = event.start_date
			
			while current_date <= end_date
				weeks << current_date.beginning_of_week
				months << current_date.beginning_of_month
				current_date += 1.day
			end
		end

		{
			weeks: weeks.size,
			months: months.size
		}
	end
end
