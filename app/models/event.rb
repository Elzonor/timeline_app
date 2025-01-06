class Event < ApplicationRecord
	belongs_to :timeline, touch: true
	
	validates :start_date, presence: true
	validate :end_date_after_start_date, if: -> { end_date.present? }
	
	private
	
	def end_date_after_start_date
		if end_date < start_date
			errors.add(:end_date, "deve essere successiva alla data di inizio")
		end
	end
end
