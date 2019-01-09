Rails.application.routes.draw do
  devise_for :users
  namespace :users do
    authenticate :user do
      resources :connections, only: [:index, :create, :destroy]
      resources :accounts, only: [:index]
      resources :transactions, only: [:index]
    end
  end

  namespace :api do
    resources :connections,  only: :index
    resources :accounts,     only: :index
    resources :transactions, only: :index
  end
end
