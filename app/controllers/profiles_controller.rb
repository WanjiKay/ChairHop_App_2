class ProfilesController < ApplicationController

  def show
    @user = User.first_or_create!(
      name: "Jane Doe",
      location: "Brooklyn, NY",
      username: "janedoe",
      about: "Plant parent, weekend woodworker, and iced coffee enthusiast."
    )
    @editing = params[:edit].present?
  end

  def update
    @user = User.first
    permitted = params.require(:user).permit(:name, :location, :userame, :about, :password_confirmation)
    permitted.except!(:password, :password_confirmation)
    if permitterd[:password].blank? if @user.update(permitted)
        redirect_to profiile_path, notice: "Profile updated."
    else
      @editing = true
      render :show, status: :unprocessable_entity
    end
  end
end
