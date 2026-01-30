# Be sure to restart your server when you modify this file.

# Handle Cross-Origin Resource Sharing (CORS) for API requests
# This is necessary for React Native mobile apps to communicate with the backend

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Allow requests from React Native development servers
    origins(
      'http://localhost:8081',      # React Native Metro bundler
      'http://localhost:19000',     # Expo dev server
      'http://localhost:19006',     # Expo web
      'http://127.0.0.1:8081',      # Alternative localhost format
      'http://127.0.0.1:19000',
      'http://127.0.0.1:19006',
      /\Aexp:\/\//                  # Expo Go app scheme
    )

    resource '/api/*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['Authorization'],
      credentials: true
  end

  # Production CORS configuration (add your production domains here)
  # allow do
  #   origins 'https://your-production-app.com'
  #
  #   resource '/api/*',
  #     headers: :any,
  #     methods: [:get, :post, :put, :patch, :delete, :options, :head],
  #     expose: ['Authorization'],
  #     credentials: true
  # end
end
