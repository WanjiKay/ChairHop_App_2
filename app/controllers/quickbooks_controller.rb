class QuickbooksController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_stylist!, except: [:callback]

  # Initiate OAuth flow
  def connect
    auth_url = build_authorization_url
    redirect_to auth_url, allow_other_host: true
  end

  # OAuth callback
  def callback
    if params[:error]
      redirect_to stylist_dashboard_path, alert: "QuickBooks connection failed: #{params[:error]}"
      return
    end

    # Exchange authorization code for tokens
    tokens = exchange_code_for_tokens(params[:code], params[:realmId])

    if tokens
      save_tokens(tokens, params[:realmId])
      redirect_to stylist_dashboard_path, notice: "QuickBooks connected successfully!"
    else
      redirect_to stylist_dashboard_path, alert: "Failed to connect to QuickBooks. Please try again."
    end
  rescue => e
    Rails.logger.error "QuickBooks OAuth error: #{e.message}"
    redirect_to stylist_dashboard_path, alert: "An error occurred connecting to QuickBooks."
  end

  # Disconnect QuickBooks
  def disconnect
    current_user.quick_books_token&.destroy
    redirect_to stylist_dashboard_path, notice: "QuickBooks disconnected."
  end

  private

  def ensure_stylist!
    redirect_to root_path, alert: "Access denied." unless current_user.stylist?
  end

  def build_authorization_url
    oauth_client = OAuth2::Client.new(
      QUICKBOOKS_CONFIG[:client_id],
      QUICKBOOKS_CONFIG[:client_secret],
      site: QUICKBOOKS_CONFIG[:auth_url],
      authorize_url: '/oauth2/v1/authorize',
      token_url: QUICKBOOKS_CONFIG[:token_url]
    )

    oauth_client.auth_code.authorize_url(
      redirect_uri: QUICKBOOKS_CONFIG[:redirect_uri],
      response_type: 'code',
      state: SecureRandom.hex(16),
      scope: 'com.intuit.quickbooks.accounting'
    )
  end

  def exchange_code_for_tokens(code, realm_id)
    oauth_client = OAuth2::Client.new(
      QUICKBOOKS_CONFIG[:client_id],
      QUICKBOOKS_CONFIG[:client_secret],
      site: QUICKBOOKS_CONFIG[:auth_url],
      token_url: QUICKBOOKS_CONFIG[:token_url]
    )

    token = oauth_client.auth_code.get_token(
      code,
      redirect_uri: QUICKBOOKS_CONFIG[:redirect_uri],
      grant_type: 'authorization_code'
    )

    {
      access_token: token.token,
      refresh_token: token.refresh_token,
      expires_at: Time.current + token.expires_in.seconds
    }
  rescue => e
    Rails.logger.error "Token exchange error: #{e.message}"
    nil
  end

  def save_tokens(tokens, realm_id)
    current_user.quick_books_token&.destroy

    current_user.create_quick_books_token!(
      access_token: tokens[:access_token],
      refresh_token: tokens[:refresh_token],
      realm_id: realm_id,
      expires_at: tokens[:expires_at]
    )
  end
end
