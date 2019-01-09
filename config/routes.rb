Rails.application.routes.draw do
  devise_for :users
  namespace :users do
    authenticate :user do
      resources :connections, only: [:index, :create, :destroy]
    end
  end
end
