class Stylist::AvailabilityBlocksController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_stylist!
  before_action :ensure_profile_complete!, only: [:new, :create]
  before_action :set_availability_block, only: [:edit, :update, :destroy]

  def index
    skip_authorization
    start_date = params.fetch(:start_date, Date.today - 1.week).to_date
    end_date   = start_date + 2.weeks

    availability_blocks = current_user.availability_blocks
      .where('start_time >= ? AND end_time <= ?', start_date, end_date)
      .includes(:location)

    appointments = current_user.appointments_as_stylist
      .where(status: [:pending, :booked])
      .where('time >= ? AND time <= ?', start_date, end_date)
      .includes(:customer)

    @calendar_events = []

    availability_blocks.each do |block|
      @calendar_events << {
        id:    "block-#{block.id}",
        title: "Available · #{block.location.name}",
        start: block.start_time.iso8601,
        end:   block.end_time.iso8601,
        color: '#4caf50',
        extendedProps: {
          type:     'availability',
          blockId:  block.id,
          location: block.location.name
        }
      }
    end

    appointments.each do |appointment|
      # selected_service is stored as "Service Name - $Price"
      service_name = appointment.selected_service&.split(' - $')&.first || 'Appointment'
      duration     = 60

      color = appointment.booked? ? '#2196F3' : '#FF9800'

      @calendar_events << {
        id:    "appointment-#{appointment.id}",
        title: service_name,
        start: appointment.time.iso8601,
        end:   (appointment.time + duration.minutes).iso8601,
        color: color,
        extendedProps: {
          type:          'appointment',
          appointmentId: appointment.id,
          customerName:  appointment.customer&.name || 'Unknown',
          serviceName:   service_name,
          status:        appointment.status,
          location:      appointment.location&.name
        }
      }
    end
  end

  def new
    skip_authorization
    @availability_block = current_user.availability_blocks.build
    @locations = current_user.locations
    @services = current_user.services.active
  end

  def create
    skip_authorization
    @availability_block = current_user.availability_blocks.build(availability_block_params)

    if @availability_block.save
      redirect_to stylist_availability_blocks_path, notice: "Availability block created successfully!"
    else
      @locations = current_user.locations
      @services = current_user.services.active
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # TODO: add AvailabilityBlockPolicy in future Pundit pass
    skip_authorization
    @locations = current_user.locations
    @services  = current_user.services.active
  end

  def update
    # TODO: add AvailabilityBlockPolicy in future Pundit pass
    skip_authorization
    if @availability_block.update(availability_block_params)
      redirect_to stylist_availability_blocks_path, notice: "Availability updated."
    else
      @locations = current_user.locations
      @services  = current_user.services.active
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    skip_authorization
    @availability_block.destroy

    respond_to do |format|
      format.html { redirect_to stylist_availability_blocks_path, notice: "Availability block deleted." }
      format.json { head :no_content }
    end
  end

  private

  def set_availability_block
    @availability_block = current_user.availability_blocks.find(params[:id])
  end

  def availability_block_params
    params.require(:availability_block).permit(
      :location_id,
      :start_time,
      :end_time,
      :available_for_all_services,
      :notes,
      service_ids: []
    )
  end

  def ensure_stylist!
    redirect_to root_path, alert: "Access denied." unless current_user.stylist?
  end

  def ensure_profile_complete!
    unless current_user.can_accept_bookings?
      if !current_user.onboarding_complete?
        redirect_to step1_stylist_onboarding_path,
                    alert: "Please complete your profile before creating availability."
      elsif !current_user.square_connected?
        redirect_to stylist_dashboard_path,
                    alert: "Please connect your Square account before creating availability."
      end
    end
  end
end
