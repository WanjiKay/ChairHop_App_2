module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      token = request.params[:token]

      if token.present?
        begin
          secret_key = Rails.application.credentials.devise_jwt_secret_key || ENV['DEVISE_JWT_SECRET_KEY']
          jwt_payload = JWT.decode(
            token.gsub('Bearer ', ''),
            secret_key,
            true,
            { algorithm: 'HS256' }
          ).first

          user = User.find(jwt_payload['sub'])

          # Check if token is denied
          if JwtDenylist.exists?(jti: jwt_payload['jti'])
            reject_unauthorized_connection
          end

          user
        rescue JWT::DecodeError, ActiveRecord::RecordNotFound
          reject_unauthorized_connection
        end
      else
        reject_unauthorized_connection
      end
    end
  end
end
