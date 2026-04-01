require 'square'
require 'net/http'
require 'openssl'

# Fix SSL CRL verification failure on macOS in development.
# The root CA cert bundle is present but CRL endpoints are unreachable,
# causing "unable to get certificate CRL" errors. Disable peer verification
# in development only — never in production.
if Rails.env.development?
  ENV['SSL_CERT_FILE'] = '/opt/homebrew/etc/openssl@3/cert.pem'

  module Net
    class HTTP
      alias_method :_original_use_ssl=, :use_ssl=

      def use_ssl=(flag)
        self._original_use_ssl = flag
        self.verify_mode = OpenSSL::SSL::VERIFY_NONE if flag
      end
    end
  end
end

SQUARE_CLIENT = Square::Client.new(
  token:    ENV['SQUARE_ACCESS_TOKEN'],
  base_url: ENV['SQUARE_ENVIRONMENT'] == 'production' ? Square::Environment::PRODUCTION : Square::Environment::SANDBOX
)

SQUARE_OAUTH_CLIENT_ID        = ENV['SQUARE_APPLICATION_ID']
SQUARE_SANDBOX_APPLICATION_ID = ENV.fetch('SQUARE_SANDBOX_APPLICATION_ID', nil)
SQUARE_OAUTH_REDIRECT_URI     = ENV['SQUARE_OAUTH_REDIRECT_URI']
