Rails.application.routes.draw do
  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    resources :timelines do
    	resources :events, module: 'timelines'
    end

    root "timelines#index"
  end
end