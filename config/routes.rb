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

  resources :conversations, only: [:index, :show] do
    resources :conversation_messages, only: [:create]
  end

  resources :messages, only: [:index, :create]

  # API routes for mobile apps
  namespace :api do
    namespace :v1 do
      # Wrap authentication routes in devise_scope
      devise_scope :user do
        post 'login', to: 'sessions#create'
        delete 'logout', to: 'sessions#destroy'
        post 'signup', to: 'registrations#create'
      end

      # Profile endpoints (requires authentication)
      get 'profile', to: 'profiles#show'
      patch 'profile', to: 'profiles#update'

      # Appointments endpoints
      resources :appointments, only: [:index, :show] do
        member do
          post :book
          delete :cancel
        end
        collection do
          get :my_appointments
        end
      end

      # Reviews endpoints
      resources :reviews, only: [:index]
      post 'appointments/:appointment_id/review', to: 'reviews#create'
      get 'appointments/:appointment_id/reviews', to: 'reviews#show'

      # Services endpoints (public browsing)
      resources :services, only: [:index, :show]

      # Stylist namespace - endpoints for stylists only
      namespace :stylist do
        resources :appointments do
          member do
            patch :accept
            patch :complete
          end
        end
        resources :services
      end
    end
  end
end
