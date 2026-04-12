class Users::RegistrationsController < Devise::RegistrationsController
  skip_after_action :verify_authorized
  before_action :configure_sign_up_params, only: [:create]
  skip_before_action :require_no_authentication, only: [:check_email]

  def check_email
    email = params[:email].to_s.strip.downcase
    available = !User.exists?(email: email)
    render json: { available: available }
  end

  protected

  def after_sign_up_path_for(resource)
    if resource.stylist?
      step1_stylist_onboarding_path
    else
      stylists_path
    end
  end

  def after_update_path_for(resource)
    if resource.stylist?
      stylist_dashboard_path
    else
      profile_path
    end
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :role, :tos_accepted_at])
    sanitize_role_param
  end

  private

  # Prevent privilege escalation: only customer/stylist are self-assignable.
  def sanitize_role_param
    return unless params[:user] && params[:user][:role].present?

    allowed = %w[customer stylist]
    params[:user][:role] = "customer" unless allowed.include?(params[:user][:role])
  end
end
