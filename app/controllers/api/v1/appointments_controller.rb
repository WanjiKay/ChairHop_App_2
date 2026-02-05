module Api
  module V1
    class AppointmentsController < BaseController
      skip_before_action :authenticate_api_user!, only: [:index, :show]
      before_action :set_appointment, only: [:show, :book, :cancel]

      # GET /api/v1/appointments
      # List all available appointments with optional filters
      def index
        @appointments = Appointment.includes(:stylist, appointment_add_ons: :service)
                                   .where(status: :pending)
                                   .order(time: :asc)

        # Apply filters
        @appointments = @appointments.where(location: params[:location]) if params[:location].present?

        # Filter by date (assuming params[:date] is in YYYY-MM-DD format)
        if params[:date].present?
          begin
            date = Date.parse(params[:date])
            @appointments = @appointments.where('DATE(time) = ?', date)
          rescue ArgumentError
            # Invalid date format, skip filter
          end
        end

        if params[:service_id].present?
          @appointments = @appointments.joins(appointment_add_ons: :service)
                                       .where(services: { id: params[:service_id] })
        end

        # Pagination
        page = params[:page] || 1
        per_page = params[:per_page] || 20
        @appointments = @appointments.page(page).per(per_page)

        render json: {
          appointments: @appointments.map { |apt| appointment_json(apt) },
          meta: {
            current_page: @appointments.current_page,
            total_pages: @appointments.total_pages,
            total_count: @appointments.total_count,
            per_page: per_page.to_i
          }
        }, status: :ok
      end

      # GET /api/v1/appointments/:id
      # Show single appointment details
      def show
        # Authorization: anyone can view pending, only involved parties can view booked/completed
        if @appointment.pending?
          # Anyone can view pending appointments
        else
          # Only customer or stylist can view their appointments
          authorize @appointment
        end

        render json: {
          appointment: appointment_detail_json(@appointment)
        }, status: :ok
      end

      # POST /api/v1/appointments/:id/book
      # Book an available appointment
      def book
        unless current_user.customer?
          render json: { error: 'Only customers can book appointments' }, status: :forbidden
          return
        end

        authorize @appointment, :book?

        unless @appointment.pending?
          render json: { error: 'This appointment is no longer available' }, status: :unprocessable_entity
          return
        end

        if @appointment.customer_id.present?
          render json: { error: 'This appointment is already booked' }, status: :unprocessable_entity
          return
        end

        ActiveRecord::Base.transaction do
          # Assign customer
          @appointment.customer_id = current_user.id

          # Set selected service
          @appointment.selected_service = params[:selected_service] if params[:selected_service].present?

          # Create add-ons from service IDs
          if params[:add_on_ids].present?
            Array(params[:add_on_ids]).each do |service_id|
              service = Service.find_by(id: service_id)
              if service
                @appointment.appointment_add_ons.create!(
                  service_id: service.id
                )
              end
            end
          end

          unless @appointment.save
            render json: {
              error: 'Failed to book appointment',
              errors: @appointment.errors.full_messages
            }, status: :unprocessable_entity
            raise ActiveRecord::Rollback
            return
          end
        end

        render json: {
          appointment: appointment_detail_json(@appointment.reload),
          message: 'Booking request sent to stylist'
        }, status: :ok
      end

      # DELETE /api/v1/appointments/:id/cancel
      # Cancel a booked appointment
      def cancel
        # Verify the customer owns this booking
        unless @appointment.customer_id == current_user.id
          render json: { error: 'Unauthorized' }, status: :forbidden
          return
        end

        # Can only cancel pending or booked appointments
        unless @appointment.pending? || @appointment.booked?
          render json: {
            error: 'Cannot cancel',
            message: 'Only pending or booked appointments can be cancelled'
          }, status: :unprocessable_entity
          return
        end

        # Clear the customer and reset to available
        @appointment.update(
          customer_id: nil,
          selected_service: nil,
          status: :pending,
          booked: false
        )

        render json: {
          message: 'Booking cancelled successfully',
          appointment: appointment_json(@appointment)
        }, status: :ok
      end

      # GET /api/v1/my_appointments
      # Show current user's appointments
      def my_appointments
        if current_user.customer?
          @appointments = Appointment.includes(:stylist, appointment_add_ons: :service)
                                     .where(customer_id: current_user.id)
        elsif current_user.stylist?
          @appointments = Appointment.includes(:customer, appointment_add_ons: :service)
                                     .where(stylist_id: current_user.id)
        else
          @appointments = Appointment.none
        end

        # Filter by status if provided
        if params[:status].present?
          @appointments = @appointments.where(status: params[:status])
        end

        # Order by time (most recent first)
        @appointments = @appointments.order(time: :desc)

        # Pagination
        page = params[:page] || 1
        per_page = params[:per_page] || 20
        @appointments = @appointments.page(page).per(per_page)

        render json: {
          appointments: @appointments.map { |apt| appointment_detail_json(apt) },
          meta: {
            current_page: @appointments.current_page,
            total_pages: @appointments.total_pages,
            total_count: @appointments.total_count,
            per_page: per_page.to_i
          }
        }, status: :ok
      end

      private

      def set_appointment
        @appointment = Appointment.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Appointment not found' }, status: :not_found
      end

      # Basic appointment JSON for list views
      def appointment_json(appointment)
        {
          id: appointment.id,
          time: appointment.time,
          date: appointment.time&.to_date,
          location: appointment.location,
          status: appointment.status,
          selected_service: appointment.selected_service,
          stylist: {
            id: appointment.stylist.id,
            name: appointment.stylist.name,
            username: appointment.stylist.username,
            location: appointment.stylist.location,
            avatar_url: appointment.stylist.avatar.attached? ? url_for(appointment.stylist.avatar) : nil
          },
          services: appointment.appointment_add_ons.map { |add_on|
            if add_on.service.present?
              {
                id: add_on.service.id,
                name: add_on.service.name,
                description: add_on.service.description,
                price: add_on.service.price,
                price_cents: add_on.service.price_cents
              }
            else
              # Legacy add-on without service
              {
                id: nil,
                name: add_on.service_name,
                description: nil,
                price: add_on.price,
                price_cents: (add_on.price * 100).to_i
              }
            end
          }.compact
        }
      end

      # Detailed appointment JSON for show/book views
      def appointment_detail_json(appointment)
        base = appointment_json(appointment)

        # Add customer info if present
        if appointment.customer.present?
          base[:customer] = {
            id: appointment.customer.id,
            name: appointment.customer.name,
            username: appointment.customer.username,
            location: appointment.customer.location,
            avatar_url: appointment.customer.avatar.attached? ? url_for(appointment.customer.avatar) : nil
          }
        end

        # Add add-ons
        base[:add_ons] = appointment.appointment_add_ons.map { |add_on|
          {
            id: add_on.id,
            name: add_on.final_name,
            price: add_on.final_price
          }
        }

        # Calculate total price
        services_price = appointment.appointment_add_ons.sum { |add_on| add_on.final_price || 0 }
        base[:total_price] = services_price

        # Add timestamps
        base[:created_at] = appointment.created_at
        base[:updated_at] = appointment.updated_at

        base
      end
    end
  end
end
