QUICKBOOKS_CONFIG = {
  client_id: ENV['QUICKBOOKS_CLIENT_ID'],
  client_secret: ENV['QUICKBOOKS_CLIENT_SECRET'],
  redirect_uri: ENV['QUICKBOOKS_REDIRECT_URI'],
  environment: ENV['QUICKBOOKS_ENVIRONMENT'] || 'sandbox',
  sandbox_base_url: 'https://sandbox-quickbooks.api.intuit.com',
  production_base_url: 'https://quickbooks.api.intuit.com',
  auth_url: 'https://appcenter.intuit.com/connect/oauth2',
  token_url: 'https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer'
}.freeze
