class ProfilesController < ApplicationController
  before_action :authenticate_user!

  # GET /profile
  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  # GET /profile/edit
  def edit
    # Reuse the show template, but force editing mode
    @editing = true
    render :show
  end

  # PATCH /profile
  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to profile_path, notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :avatar)
  end
end
