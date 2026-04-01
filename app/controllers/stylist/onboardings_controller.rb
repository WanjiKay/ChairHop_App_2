class Stylist::OnboardingsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_stylist!
  before_action :check_already_completed, except: [:step1, :complete_step1]

  # Step 1: Profile Photo & Bio
  def step1
    skip_authorization
    @user = current_user
  end

  def complete_step1
    skip_authorization
    @user = current_user
    if @user.update(step1_params)
      redirect_to step2_stylist_onboarding_path, notice: "Profile updated!"
    else
      render :step1, status: :unprocessable_entity
    end
  end

  # Step 2: Add First Service
  def step2
    skip_authorization
    @service = current_user.services.build
  end

  def complete_step2
    skip_authorization
    @service = current_user.services.build(service_params)
    if @service.save
      redirect_to step3_stylist_onboarding_path
    else
      render :step2, status: :unprocessable_entity
    end
  end

  # Step 3: Add First Location
  def step3
    skip_authorization
    @location = current_user.locations.build
  end

  def complete_step3
    skip_authorization
    @location = current_user.locations.build(location_params)
    if @location.save
      redirect_to step4_stylist_onboarding_path
    else
      render :step3, status: :unprocessable_entity
    end
  end

  # Step 4: First Availability Block (Optional)
  def step4
    skip_authorization
    @availability_block = current_user.availability_blocks.build
    @locations = current_user.locations
  end

  def complete_step4
    skip_authorization
    @availability_block = current_user.availability_blocks.build(availability_params)
    if @availability_block.save
      complete_onboarding!
    else
      @locations = current_user.locations
      render :step4, status: :unprocessable_entity
    end
  end

  def skip_step4
    skip_authorization
    complete_onboarding!
  end

  private

  def ensure_stylist!
    redirect_to root_path, alert: "Access denied." unless current_user.stylist?
  end

  def check_already_completed
    if current_user.onboarding_completed_at.present?
      redirect_to stylist_dashboard_path, notice: "Onboarding already completed!"
    end
  end

  def complete_onboarding!
    current_user.mark_onboarding_complete!
    redirect_to stylist_dashboard_path, notice: "Welcome to ChairHop! Your profile is ready."
  end

  def step1_params
    params.require(:user).permit(:avatar, :about)
  end

  def service_params
    params.require(:service).permit(:name, :duration_minutes, :price, :description)
  end

  def location_params
    params.require(:location).permit(:name, :street_address, :city, :state, :zip_code)
  end

  def availability_params
    params.require(:availability_block).permit(
      :start_time, :end_time, :location_id,
      :available_for_all_services, service_ids: []
    )
  end
end
