Geocoder.configure(
  # Geocoding service
  lookup: :mapbox,

  # Mapbox API key
  api_key: ENV['MAPBOX_API_KEY'],

  # Timeout for geocoding requests
  timeout: 5,

  # Units for distance calculations
  units: :mi,

  # Cache geocoding results
  cache: Rails.cache,
  cache_prefix: 'geocoder:',

  # SSL settings (skip verification in development to fix certificate errors)
  use_https: true,
  ssl_verify_peer: Rails.env.production?
)
