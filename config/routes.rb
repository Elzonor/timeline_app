Rails.application.routes.draw do
  
  resources :timelines do
  	resources :events, module: 'timelines'
  end

	root "timelines#index"
  
end