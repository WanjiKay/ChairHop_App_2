class ProfilesController < ApplicationController
  before_action :authenticate_user!

  # GET /profile
  def show
    skip_authorization
    @user = current_user
    if current_user.customer?
      base = Appointment.where(customer_id: current_user.id)
                        .includes(:stylist, :location)
                        .order(time: :desc)
      @upcoming = base.where(status: :booked)
      @pending  = base.where(status: :pending)
    end
  end

  # GET /profile/edit
  def edit
    skip_authorization
    @user = current_user
  end

  # PATCH /profile
  def update
    skip_authorization
    @user = current_user
    if @user.update(user_params)
      redirect_to profile_path, notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  rescue ActiveStorage::IntegrityError => e
    flash[:alert] = if e.message.include?("File size too large")
      "One or more photos are too large. Each photo must be under 10MB. Please compress your images and try again."
    else
      "Photo upload failed: #{e.message}"
    end
    render :edit, status: :unprocessable_entity
  end

  def destroy_portfolio_photo
    skip_authorization
    photo = current_user.portfolio_photos.find(params[:photo_id])
    photo.purge
    redirect_to edit_profile_path, notice: "Photo removed."
  end

  def upload_portfolio_photos
    skip_authorization
    photos = Array(params.dig(:user, :portfolio_photos)).reject(&:blank?)

    if photos.empty?
      render json: { error: "No photos selected." },
             status: :unprocessable_entity
      return
    end

    existing_count = current_user.portfolio_photos.count
    if existing_count + photos.length > 12
      render json: {
        error: "You can only have 12 portfolio photos total. " \
               "You currently have #{existing_count} — " \
               "you can add #{12 - existing_count} more."
      }, status: :unprocessable_entity
      return
    end

    photos.each { |photo| current_user.portfolio_photos.attach(photo) }
    render json: {
      success: true,
      message: "#{photos.length} photo(s) uploaded successfully!",
      total: current_user.portfolio_photos.count
    }
  rescue ActiveStorage::IntegrityError => e
    render json: {
      error: e.message.include?("File size too large") ?
        "One or more photos exceed the 10MB limit. Please compress and try again." :
        "Upload failed: #{e.message}"
    }, status: :unprocessable_entity
  end

  def apply_hopps_bio
    authorize current_user, policy_class: ProfilePolicy
    bio = params[:bio].to_s.strip
    if bio.length < 50
      render json: { error: "Bio must be at least 50 characters." }, status: :unprocessable_entity
      return
    end
    if current_user.update(about: bio)
      render json: { success: true, message: "Bio applied to your profile!" }
    else
      render json: { error: current_user.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  def user_params
    params.require(:user).permit(:name, :email, :avatar, :about,
                                  :street_address, :city, :state, :zip_code)
  end
end
