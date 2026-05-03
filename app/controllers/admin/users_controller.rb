class Admin::UsersController < Admin::BaseController
  def index
    @stylists = User.stylist.order(:last_name, :first_name)
  end

  def toggle_founding_stylist
    @user = User.find(params[:id])
    @user.update!(founding_stylist: !@user.founding_stylist?)
    redirect_to admin_users_path, notice: "#{@user.full_name} updated."
  end
end
