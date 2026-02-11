class Stylist::ServicesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_stylist!
  before_action :set_service, only: [:edit, :update, :destroy]

  def index
    @services = current_user.services.order(:name)
  end

  def new
    @service = current_user.services.build
  end

  def create
    @service = current_user.services.build(service_params)
    if @service.save
      redirect_to stylist_services_path, notice: "Service created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @service.update(service_params)
      redirect_to stylist_services_path, notice: "Service updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @service.appointment_add_ons.exists?
      @service.update(active: false)
      redirect_to stylist_services_path, notice: "Service deactivated (linked to past appointments)."
    else
      @service.destroy
      redirect_to stylist_services_path, notice: "Service deleted."
    end
  end

  private

  def set_service
    @service = current_user.services.find(params[:id])
  end

  def service_params
    params.require(:service).permit(:name, :description, :price, :duration_minutes, :active)
  end

  def ensure_stylist!
    redirect_to root_path, alert: "Access denied" unless current_user.stylist?
  end
end
