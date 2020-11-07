Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    resources :currencies, only: [] do
      collection do
        get 'convert/:base_currency', to: 'currencies#convert'
      end
    end
  end
end
