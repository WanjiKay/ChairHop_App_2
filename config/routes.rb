Rails.application.routes.draw do
  root to: "pages#home"

  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  # Stylist portal
  namespace :stylist do
    get "/", to: "dashboard#index", as: :dashboard
    resources :services, except: [:show]
    resources :locations
    resources :availability_blocks, path: 'calendar', only: [:index, :new, :create, :edit, :update, :destroy]

    resource :onboarding, only: [] do
      get  :step1,          on: :collection
      post :complete_step1, on: :collection
      get  :step2,          on: :collection
      post :complete_step2, on: :collection
      get  :step3,          on: :collection
      post :complete_step3, on: :collection
      get  :step4,          on: :collection
      post :complete_step4, on: :collection
      post :skip_step4,     on: :collection
    end

    resources :appointments, only: [:index, :new, :create] do
      member do
        patch :accept
        patch :decline
        patch :cancel
        patch :complete
        patch :send_payment_link
      end
    end

    resources :review_responses, only: [:create, :update], param: :review_id
    resources :reviews, only: [:index]
    get 'analytics', to: 'analytics#index', as: :analytics
  end

  # Square webhooks
  namespace :webhooks do
    post 'square', to: 'square#receive'
  end

  # Square OAuth
  get    '/square/connect',    to: 'square#connect',    as: :connect_square
  get    '/square/callback',   to: 'square#callback',   as: :square_callback
  delete '/square/disconnect', to: 'square#disconnect', as: :disconnect_square

  get 'bookings/slots', to: 'bookings#slots', as: :booking_slots
  resources :bookings, only: [:new, :create]

  delete 'profile/portfolio_photos/:photo_id',
    to: 'profiles#destroy_portfolio_photo',
    as: :destroy_portfolio_photo

  post 'profile/portfolio_photos/upload',
    to: 'profiles#upload_portfolio_photos',
    as: :upload_portfolio_photos

  resource :profile, only: [:show, :edit, :update]

  resources :appointments do
    resources :chats, only: [:index, :show, :new, :create]
    resources :conversations, only: [:index, :show, :new, :create]
    resources :reviews, only: [:new, :create, :edit, :update]

    member do
      get :review
      post :review
      get :confirmation
      get :balance_receipt
      get :invoice
      post :book
      get :booked
      get :payment_failed
      patch :complete
      patch :cancel
    end
  end

  get "my_appointments", to: "appointments#my_appointments", as: :my_appointments

  get '/book/:slug', to: 'stylists#booking_page', as: :stylist_booking_page

  resources :stylists, only: [:index, :show]

  resources :chats, only: [:index, :new, :create, :show] do
    resources :messages, only: [:create]
  end

  resources :conversations, only: [:index, :show] do
    resources :conversation_messages, only: [:create]
  end

  resources :messages, only: [:index, :create]
end
