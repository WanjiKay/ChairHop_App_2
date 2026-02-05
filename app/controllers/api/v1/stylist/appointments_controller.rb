module Api
  module V1
    module Stylist
      class AppointmentsController < BaseController
        before_action :verify_stylist!
        before_action :set_appointment, only: [:accept, :complete, :destroy]

        # GET /api/v1/stylist/appointments
        # List all appointments for current stylist
        def index
          @appointments = Appointment.includes(:customer, appointment_add_ons: :service)
                                     .where(stylist_id: current_user.id)

          # Filter by status if provided
          if params[:status].present?
            @appointments = @appointments.where(status: params[:status])
          end

          # Order by time (upcoming first for pending/booked, most recent first for completed)
          if params[:status] == 'completed'
            @appointments = @appointments.order(time: :desc)
          else
            @appointments = @appointments.order(time: :asc)
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

        # POST /api/v1/stylist/appointments
        # Create new availability slot
        def create
          @appointment = Appointment.new(appointment_params)
          @appointment.stylist_id = current_user.id
          @appointment.status = :pending
          @appointment.booked = false

          if @appointment.save
            render json: {
              appointment: appointment_json(@appointment),
              message: 'Availability created successfully'
            }, status: :created
          else
            Rails.logger.error "Appointment validation errors: #{@appointment.errors.full_messages}"
            render json: {
              error: 'Failed to create availability',
              errors: @appointment.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        # PATCH /api/v1/stylist/appointments/:id/accept
        # Accept a pending booking request from customer
        def accept
          unless @appointment.pending?
            render json: {
              error: 'Cannot accept',
              message: 'Only pending appointments can be accepted'
            }, status: :unprocessable_entity
            return
          end

          unless @appointment.customer_id.present?
            render json: {
              error: 'Cannot accept',
              message: 'No customer has requested this appointment yet'
            }, status: :unprocessable_entity
            return
          end

          if @appointment.accept!
            # Send notification to customer
            notification_service = PushNotificationService.new
            notification_service.send_to_user(
              @appointment.customer,
              'Booking Accepted!',
              "#{@appointment.stylist.name} accepted your appointment",
              { type: 'booking_accepted', appointment_id: @appointment.id }
            )

            render json: {
              appointment: appointment_json(@appointment.reload),
              message: 'Booking accepted successfully'
            }, status: :ok
          else
            render json: {
              error: 'Failed to accept booking',
              errors: @appointment.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        # PATCH /api/v1/stylist/appointments/:id/complete
        # Mark appointment as completed
        def complete
          unless @appointment.booked?
            render json: {
              error: 'Cannot complete',
              message: 'Only booked appointments can be marked as completed'
            }, status: :unprocessable_entity
            return
          end

          unless @appointment.time < Time.current
            render json: {
              error: 'Cannot complete',
              message: 'Appointment time must have passed before marking as completed'
            }, status: :unprocessable_entity
            return
          end

          if @appointment.update(status: :completed)
            # Send notification to customer
            notification_service = PushNotificationService.new
            notification_service.send_to_user(
              @appointment.customer,
              'Please Review',
              "How was your appointment with #{@appointment.stylist.name}?",
              { type: 'review_request', appointment_id: @appointment.id }
            )

            render json: {
              appointment: appointment_json(@appointment),
              message: 'Appointment marked as completed'
            }, status: :ok
          else
            render json: {
              error: 'Failed to complete appointment',
              errors: @appointment.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        # DELETE /api/v1/stylist/appointments/:id
        # Cancel/delete an appointment
        def destroy
          if @appointment.customer_id.present?
            # Customer is assigned, cancel the appointment
            if @appointment.cancel!
              render json: {
                message: 'Appointment cancelled successfully'
              }, status: :ok
            else
              render json: {
                error: 'Failed to cancel appointment',
                errors: @appointment.errors.full_messages
              }, status: :unprocessable_entity
            end
          else
            # No customer assigned, just delete the availability slot
            if @appointment.destroy
              render json: {
                message: 'Availability slot deleted successfully'
              }, status: :ok
            else
              render json: {
                error: 'Failed to delete appointment',
                errors: @appointment.errors.full_messages
              }, status: :unprocessable_entity
            end
          end
        end

        private

        def verify_stylist!
          unless current_user.stylist?
            render json: {
              error: 'Forbidden',
              message: 'Only stylists can access this endpoint'
            }, status: :forbidden
          end
        end

        def appointment_params
          params.require(:appointment).permit(:time, :location, :services)
        end

        def set_appointment
          @appointment = Appointment.find(params[:id])

          # Verify appointment belongs to current stylist
          unless @appointment.stylist_id == current_user.id
            render json: {
              error: 'Forbidden',
              message: 'This appointment does not belong to you'
            }, status: :forbidden
          end
        rescue ActiveRecord::RecordNotFound
          render json: { error: 'Appointment not found' }, status: :not_found
        end

        def appointment_json(appointment)
          data = {
            id: appointment.id,
            time: appointment.time,
            date: appointment.time&.to_date,
            location: appointment.location,
            status: appointment.status,
            booked: appointment.booked,
            selected_service: appointment.selected_service,
            services_text: appointment.services,
            created_at: appointment.created_at,
            updated_at: appointment.updated_at
          }

          # Add customer info if present
          if appointment.customer.present?
            data[:customer] = {
              id: appointment.customer.id,
              name: appointment.customer.name,
              username: appointment.customer.username,
              location: appointment.customer.location,
              avatar_url: appointment.customer.avatar.attached? ? url_for(appointment.customer.avatar) : nil
            }
          end

          # Add add-ons/services
          data[:add_ons] = appointment.appointment_add_ons.map { |add_on|
            {
              id: add_on.id,
              name: add_on.final_name,
              price: add_on.final_price
            }
          }

          # Calculate total price
          data[:total_price] = appointment.appointment_add_ons.sum { |add_on| add_on.final_price || 0 }

          data
        end
      end
    end
  end
end
