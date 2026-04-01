class Stylist::LocationsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_stylist!
  before_action :set_location, only: [:edit, :update, :destroy]

  def index
    skip_authorization
    @locations = current_user.locations.order(:name)
  end

  def new
    @location = current_user.locations.build
    authorize @location
  end

  def create
    @location = current_user.locations.build(location_params)
    authorize @location

    if @location.save
      redirect_to stylist_locations_path, notice: "Location added successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @location
  end

  def update
    authorize @location
    if @location.update(location_params)
      redirect_to stylist_locations_path, notice: "Location updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @location
    @location.destroy
    redirect_to stylist_locations_path, notice: "Location deleted."
  end

  private

  def set_location
    @location = current_user.locations.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:name, :street_address, :city, :state, :zip_code)
  end

  def ensure_stylist!
    redirect_to root_path, alert: "Access denied." unless current_user.stylist?
  end
end
