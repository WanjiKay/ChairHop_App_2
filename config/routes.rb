Rails.application.routes.draw do
  get 'stylists/show'
  root to: "pages#home"

  devise_for :users

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  resource :profile, only: [:show, :edit, :update]
  get "/profile", to: "profile#show"

  resources :appointments do
    resources :chats, only: [:index, :show, :new, :create]
  end

  resources :stylists, only: [:show]

  post "appointment/:id/book", to: "appointments#book", as: :book_appointment

  resources :chats, only: [:index, :new, :create, :show]
  resources :messages, only: [:index, :create]
end
