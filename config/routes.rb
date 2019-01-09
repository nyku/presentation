Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions:      "users/sessions",
  }

  namespace :users do
    authenticate :user do
      resources :connections, only: [:index, :create, :update, :destroy]
      resources :accounts, only: [:index]
      resources :transactions, only: [:index]
    end
  end

  namespace :api do
    resources :connections,  only: [:index, :show, :update, :destroy]
    resources :accounts,     only: :index
    resources :transactions, only: :index
  end

  root "users/connections#index"
end
