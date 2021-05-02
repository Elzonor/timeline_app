Rails.application.routes.draw do
  
  resources :timelines do
  	resources :events
  end

	root "timelines#index"
  
end
