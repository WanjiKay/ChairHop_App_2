class SquareController < ApplicationController
  before_action :authenticate_user!, except: [:callback]
  before_action :ensure_stylist!, except: [:callback]

  # Initiate Square OAuth flow
  def connect
    skip_authorization
    oauth_url = if square_environment == 'production'
      "https://connect.squareup.com/oauth2/authorize"
    else
      "https://connect.squareupsandbox.com/oauth2/authorize"
    end

    query = {
      client_id: SQUARE_OAUTH_CLIENT_ID,
      scope:     'MERCHANT_PROFILE_READ PAYMENTS_WRITE PAYMENTS_READ ORDERS_WRITE CUSTOMERS_WRITE CUSTOMERS_READ',
      session:   false,
      state:     current_user.id.to_s
    }.to_query

    redirect_to "#{oauth_url}?#{query}", allow_other_host: true
  end

  # Handle Square OAuth callback (session may be lost after external redirect)
  def callback
    skip_authorization
    Rails.logger.info "========== SQUARE OAUTH CALLBACK =========="
    Rails.logger.info "Params: #{params.to_unsafe_h.except('controller', 'action').inspect}"
    Rails.logger.info "Code present: #{params[:code].present?}"
    Rails.logger.info "State (user_id): #{params[:state].inspect}"
    Rails.logger.info "Error: #{params[:error].inspect}" if params[:error].present?
    Rails.logger.info "User signed in: #{user_signed_in?}"
    Rails.logger.info "=========================================="

    if params[:error].present?
      flash[:alert] = "Square connection cancelled: #{params[:error]}"
      redirect_to new_user_session_path
      return
    end

    authorization_code = params[:code]
    user_id            = params[:state]

    unless authorization_code.present? && user_id.present?
      flash[:alert] = "Invalid OAuth response from Square."
      redirect_to new_user_session_path
      return
    end

    user = User.find_by(id: user_id)

    unless user&.stylist?
      flash[:alert] = "User not found or not a stylist."
      redirect_to new_user_session_path
      return
    end

    begin
      # v45 gem raises on error — no .success? check needed
      result = SQUARE_CLIENT.o_auth.obtain_token(
        client_id:     SQUARE_OAUTH_CLIENT_ID,
        client_secret: ENV['SQUARE_APPLICATION_SECRET'],
        code:          authorization_code,
        grant_type:    'authorization_code'
      )

      Rails.logger.info "Token exchange successful!"
      Rails.logger.info "Access token present: #{result.access_token.present?}"
      Rails.logger.info "Merchant ID: #{result.merchant_id.inspect}"

      # Fetch the stylist's active location using their own access token
      stylist_client = Square::Client.new(
        token:    result.access_token,
        base_url: square_environment == 'production' ?
                    Square::Environment::PRODUCTION :
                    Square::Environment::SANDBOX
      )

      locations_result = stylist_client.locations.list
      active_location  = locations_result.locations&.find { |loc| loc.status == 'ACTIVE' }

      unless active_location
        Rails.logger.warn "No active Square location for merchant #{result.merchant_id}"
        sign_in(user) unless user_signed_in?
        redirect_to stylist_dashboard_path,
                    alert: "Connected to Square but no active location found. Please add a location in your Square dashboard, then reconnect."
        return
      end

      Rails.logger.info "Location ID: #{active_location.id}, Name: #{active_location.name}"

      user.update!(
        square_access_token:  result.access_token,
        square_refresh_token: result.refresh_token,
        square_merchant_id:   result.merchant_id,
        square_location_id:   active_location.id,
        square_connected_at:  Time.current
      )

      Rails.logger.info "User square_connected?: #{user.reload.square_connected?}"

      sign_in(user) unless user_signed_in?
      redirect_to stylist_dashboard_path,
                  notice: "Square account connected! Location: #{active_location.name}"

    rescue => e
      Rails.logger.error "Square OAuth exception: #{e.class}: #{e.message}"
      Rails.logger.error e.backtrace.first(5).join("\n")
      sign_in(user) if user && !user_signed_in?
      redirect_to stylist_dashboard_path, alert: "Error connecting Square account. Please try again."
    end
  end

  # Disconnect Square account
  def disconnect
    skip_authorization
    token_to_revoke = current_user.square_access_token

    current_user.disconnect_square!

    begin
      SQUARE_CLIENT.o_auth.revoke_token(
        client_id:    SQUARE_OAUTH_CLIENT_ID,
        access_token: token_to_revoke,
        request_options: {
          additional_headers: { 'Authorization' => "Client #{ENV['SQUARE_APPLICATION_SECRET']}" }
        }
      )
    rescue => e
      Rails.logger.error "Failed to revoke Square token: #{e.message}"
    end

    redirect_to stylist_dashboard_path, notice: "Square account disconnected."
  end

  private

  def ensure_stylist!
    redirect_to root_path, alert: "Access denied." unless current_user&.stylist?
  end

  def square_environment
    ENV.fetch('SQUARE_ENVIRONMENT', 'sandbox')
  end
end
