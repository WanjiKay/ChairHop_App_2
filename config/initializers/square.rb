require 'square'

SQUARE_CLIENT = Square::Client.new(
  token: Rails.env.production? ? ENV['SQUARE_ACCESS_TOKEN'] : ENV['SQUARE_SANDBOX_ACCESS_TOKEN'],
  base_url: Rails.env.production? ? Square::Environment::PRODUCTION : Square::Environment::SANDBOX
)
