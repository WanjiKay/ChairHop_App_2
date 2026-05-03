class Admin::BaseController < ApplicationController
  layout "admin"
  skip_after_action :verify_authorized
  before_action :require_admin!

  private

  def require_admin!
    redirect_to root_path, alert: "Not authorized." unless current_user&.admin?
  end
end
