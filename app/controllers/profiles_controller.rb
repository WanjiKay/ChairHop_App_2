class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  # GET /profile
  def show
    # You can use this flag in your view if you want read-only vs edit modes
    @editing = params[:edit].present?
  end

  # GET /profile/edit
  def edit
    # Reuse the show template, but force editing mode
    @editing = true
    render :show
  end

  # PATCH /profile
  def update
    if @user.update(user_params)
      redirect_to edit_profile_path, notice: "Profile updated."
    else
      @editing = true
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_user
    # Always use the currently logged-in user
    @user = current_user
  end

  def user_params
    # Adjust these fields based on what your User model actually has
    params.require(:user).permit(
      :name,
      :location,
      :username,
      :about,
      :avatar
    )
  end
end
