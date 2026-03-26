class Quickbooks::ManualSetupController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_stylist!

  def new
  end

  def create
    current_user.quick_books_token&.destroy

    current_user.create_quick_books_token!(
      access_token: params[:access_token],
      refresh_token: params[:refresh_token],
      realm_id: params[:realm_id],
      expires_at: Time.current + 1.hour
    )

    redirect_to stylist_dashboard_path, notice: "QuickBooks connected successfully!"
  rescue => e
    redirect_to quickbooks_manual_setup_path, alert: "Error: #{e.message}"
  end

  private

  def ensure_stylist!
    redirect_to root_path, alert: "Access denied." unless current_user.stylist?
  end
end
