# frozen_string_literal: true

Rails.application.routes.draw do
  get 'users/index'
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  root 'books#index'

  resources :users do
    resources :books, only: %i[index show], controller: 'users/books'
  end

  get '/whats_new', to: 'pages#whats_new', as: :whats_new


  resources :friendships, only: %i[create update destroy]

  resources :comments

  resources :ratings, only: %i[create update]

  resources :books do
    collection do
      get :search
    end
    member do
      patch :lend
    end
  end

  resources :book_requests, only: %i[create index show] do
    member do
      patch :accept
      patch :decline
      patch :mark_lent
    end
  end

  resources :friends
end
