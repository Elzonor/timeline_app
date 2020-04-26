class Event < ApplicationRecord
	belongs_to :timeline, dependent: :destroy
end
