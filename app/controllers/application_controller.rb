class ApplicationController < ActionController::Base
  include Pundit::Authorization
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  after_action :verify_authorized, unless: :devise_controller?

  rescue_from Pundit::NotAuthorizedError,        with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound,      with: :not_found

  def default_url_options
    { host: ENV["DOMAIN"] || "localhost:3000" }
  end

  def after_sign_in_path_for(resource)
    # New stylist who hasn't completed onboarding takes priority over stored location
    if resource.stylist? && resource.onboarding_completed_at.nil?
      step1_stylist_onboarding_path
    elsif resource.stylist?
      stored_location_for(resource) || stylist_dashboard_path
    else
      stored_location_for(resource) || stylists_path
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :role])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :role])
    sanitize_role_param
  end

  def sanitize_role_param
    return unless params[:user] && params[:user][:role].present?

    allowed = %w[customer stylist]
    params[:user][:role] = "customer" unless allowed.include?(params[:user][:role])
  end

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end

  def not_found
    flash[:alert] = "That page could not be found."
    redirect_back(fallback_location: root_path)
  end
end
