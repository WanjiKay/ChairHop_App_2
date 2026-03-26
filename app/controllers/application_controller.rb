class ApplicationController < ActionController::Base
  include Pundit::Authorization
  before_action :authenticate_user!

  # Rescue from Pundit authorization errors
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def default_url_options
    { host: ENV["DOMAIN"] || "localhost:3000" }
  end

  def after_sign_in_path_for(resource)
    resource.stylist? ? stylist_dashboard_path : root_path
  end

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end
end
