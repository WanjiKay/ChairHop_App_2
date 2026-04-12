class BookingsController < ApplicationController
  before_action :authenticate_user!

  def new
    skip_authorization
    @stylist = User.where(role: :stylist).find(params[:stylist_id])
    @availability_block = if params[:availability_block_id].present?
      @stylist.availability_blocks
        .where('end_time > ?', Time.current)
        .find(params[:availability_block_id])
    end

    # Load all future availability blocks for the date picker
    @availability_blocks = @stylist.availability_blocks
      .includes(:location)
      .where('end_time > ?', Time.current)
      .order(:start_time)

    # Build date → blocks map for the JS date picker
    @blocks_by_date = @availability_blocks.group_by { |b|
      b.start_time.to_date.to_s
    }

    # Services available (from pre-selected block or all stylist services)
    @services = if @availability_block
      @availability_block.available_services.main_services
        .includes(photo_attachment: :blob)
    else
      @stylist.services.active.main_services
        .includes(photo_attachment: :blob)
    end
  end

  def slots
    skip_authorization
    # AJAX endpoint: returns time slots for a given date + stylist
    stylist = User.where(role: :stylist).find(params[:stylist_id])
    date = Date.parse(params[:date])

    blocks = stylist.availability_blocks
      .includes(:location)
      .where('DATE(start_time) = ? AND end_time > ?', date, Time.current)

    slots = blocks.flat_map do |block|
      result = []
      t = block.start_time
      while t + 30.minutes <= block.end_time
        # Only include future slots not overlapping existing booked/pending appointments.
        # Handle appointments with nil end_time by assuming a 60-min default duration.
        overlapping = Appointment.where(stylist_id: stylist.id)
          .where.not(customer_id: nil)
          .where(
            "(status = ? AND (hold_expires_at IS NULL OR hold_expires_at >= ?)) OR status = ?",
            Appointment.statuses[:pending], Time.current, Appointment.statuses[:booked]
          )
          .where(
            '(end_time IS NOT NULL AND time < ? AND end_time > ?) OR
             (end_time IS NULL AND time >= ? AND time < ?)',
            t + 30.minutes, t,
            t, t + 60.minutes
          )
          .exists?
        result << {
          time: t.iso8601,
          label: t.strftime("%-I:%M %p"),
          location: block.location&.name,
          block_id: block.id,
          location_id: block.location_id
        } unless overlapping
        t += 30.minutes
      end
      result
    end

    render json: { slots: slots }
  rescue ArgumentError
    render json: { slots: [] }
  end

  def create
    skip_authorization
    stylist = User.where(role: :stylist).find(params[:stylist_id])

    # Parse the selected time and find its availability block
    selected_time = Time.parse(params[:selected_time])
    block_id = params[:availability_block_id]
    block = stylist.availability_blocks.find_by(id: block_id)

    unless block
      redirect_to stylist_path(stylist, anchor: 'book'),
        alert: "Could not find that availability block. Please try again."
      return
    end

    # Calculate end_time from service duration
    service = stylist.services.find_by(name: params[:selected_service_name])
    duration = service&.duration_minutes || 60
    end_time = selected_time + duration.minutes

    # Build the appointment with a 10-minute hold
    appointment = Appointment.new(
      stylist: stylist,
      time: selected_time,
      end_time: end_time,
      location_id: block.location_id,
      availability_block_id: block.id,
      salon: stylist.name,
      selected_service: "#{service&.name} - $#{sprintf('%.2f', service&.price || 0)}",
      status: :pending,
      payment_amount: 0,
      payment_status: 'pending',
      hold_expires_at: Time.current + 10.minutes
    )

    if appointment.save
      # Handle add-ons
      raw = params[:add_on_ids]
      add_on_ids = case raw
        when Array  then raw.map(&:to_i).reject(&:zero?)
        when String then raw.split(',').map(&:to_i).reject(&:zero?)
        else []
      end

      if add_on_ids.any?
        add_on_services = stylist.services.where(id: add_on_ids)
        add_on_services.each do |addon|
          appointment.appointment_add_ons.create!(
            service_id: addon.id,
            service_name: addon.name,
            price: addon.price
          )
        end
      end

      # Store service selection in session for the review page
      session_key = "appointment_#{appointment.id}_selections"
      session[session_key] = {
        "selected_service" => appointment.selected_service,
        "add_on_ids" => add_on_ids,
        "selected_time" => selected_time.iso8601
      }
      redirect_to review_appointment_path(appointment)
    else
      redirect_to stylist_path(stylist, anchor: 'book'),
        alert: "Could not create appointment: #{appointment.errors.full_messages.join(', ')}"
    end
  end
end
