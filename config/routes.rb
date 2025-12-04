Rails.application.routes.draw do
  root to: "pages#home"

  devise_for :users

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  resource :profile, only: [:show, :edit, :update]

  resources :appointments do
    resources :chats, only: [:index, :show, :new, :create]
    resources :conversations, only: [:index, :show, :new, :create]
    resources :reviews, only: [:new, :create]

    member do
      get :check_in
      post :check_in
      get :confirmation
      post :book
      get :booked
      patch :complete
    end
  end

  get "my_appointments", to: "appointments#my_appointments", as: :my_appointments

  resources :stylists, only: [:show]

  resources :chats, only: [:index, :new, :create, :show] do
    resources :messages, only: [:create]
  end

  resources :conversations, only: [:show] do
    resources :conversation_messages, only: [:create]
  end

  resources :messages, only: [:index, :create]

end
