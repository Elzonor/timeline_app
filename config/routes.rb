Rails.application.routes.draw do
  resources :timelines
  resources :events

	root "timelines#index"
end
