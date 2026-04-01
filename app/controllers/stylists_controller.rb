class StylistsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :stylist_not_found

  def index
    skip_authorization

    # Base: join availability_blocks so subsequent filters can reference the table directly.
    # Only stylists who have at least one future block.
    @stylists = User.where(role: :stylist)
      .joins(:availability_blocks)
      .where('availability_blocks.end_time > ?', Time.current)
      .includes(:locations, :services)
      .distinct

    # Name / address text search (users.location was dropped; check locations table via subquery)
    if params[:search].present?
      term = "%#{params[:search]}%"
      @stylists = @stylists.where(
        "users.name ILIKE :t OR users.city ILIKE :t OR users.state ILIKE :t OR users.zip_code ILIKE :t OR " \
        "EXISTS (SELECT 1 FROM locations l WHERE l.user_id = users.id AND " \
        "(LOWER(l.city) LIKE :t OR LOWER(l.state) LIKE :t OR LOWER(l.street_address) LIKE :t))",
        t: term
      )
    end

    # Service filter — stylist offers the service AND the availability block covers it
    # (either available_for_all_services, or the service id is in the block's service_ids array)
    if params[:service].present?
      service_term = "%#{params[:service].downcase}%"
      @stylists = @stylists
        .joins("INNER JOIN services ON services.stylist_id = users.id")
        .where("LOWER(services.name) LIKE ?", service_term)
        .where(
          "availability_blocks.available_for_all_services = true OR " \
          "services.id::text = ANY(availability_blocks.service_ids)"
        )
    end

    # Date filter — stylist has a block that spans the given date
    if params[:date].present?
      begin
        date = Date.parse(params[:date])
        @stylists = @stylists.where(
          'availability_blocks.start_time <= ? AND availability_blocks.end_time >= ?',
          date.end_of_day, date.beginning_of_day
        )
      rescue ArgumentError
        # invalid date param — ignore
      end
    end

    # Location filter — stylist's block is at a matching location
    if params[:location].present?
      location_term = "%#{params[:location].downcase}%"
      @stylists = @stylists
        .joins("INNER JOIN locations ON locations.id = availability_blocks.location_id")
        .where(
          "LOWER(locations.city) LIKE :t OR LOWER(locations.name) LIKE :t OR LOWER(locations.street_address) LIKE :t",
          t: location_term
        )
    end

    @stylists = @stylists.order("users.name")
  end

  def show
    skip_authorization
    @stylist = User.where(role: :stylist)
      .includes(portfolio_photos_attachments: :blob)
      .find(params[:id])
    load_stylist_show_data
  end

  def booking_page
    skip_authorization
    @stylist = User.where(role: :stylist)
      .includes(portfolio_photos_attachments: :blob)
      .find_by!(booking_slug: params[:slug])
    load_stylist_show_data
    render :show
  rescue ActiveRecord::RecordNotFound
    redirect_to stylists_path,
      alert: "That booking link doesn't exist."
  end

  private

  def load_stylist_show_data
    @reviews = @stylist.reviews_for_stylist
      .includes(:customer, photos_attachments: :blob)
    @services = @stylist.services.active
      .includes(photo_attachment: :blob)
      .main_services
    @availability_blocks = @stylist.availability_blocks
      .where('end_time > ?', Time.current)
      .includes(:location)
      .order(:start_time)

    @available_dates = @stylist.availability_blocks
      .where('end_time > ?', Time.current)
      .pluck(:start_time)
      .map { |t| t.to_date.to_s }
      .uniq
      .sort
  end

  def stylist_not_found
    redirect_to stylists_path, alert: "Stylist not found."
  end
end
