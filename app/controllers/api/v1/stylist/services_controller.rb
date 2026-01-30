module Api
  module V1
    module Stylist
      class ServicesController < BaseController
        before_action :verify_stylist!
        before_action :set_service, only: [:show, :update, :destroy]

        # GET /api/v1/stylist/services
        # List all services for current stylist
        def index
          @services = Service.where(stylist_id: current_user.id)

          # Filter by active status if provided
          if params[:active].present?
            @services = @services.where(active: params[:active] == 'true')
          end

          # Order by created_at desc (most recent first)
          @services = @services.order(created_at: :desc)

          # Pagination
          page = params[:page] || 1
          per_page = params[:per_page] || 20
          @services = @services.page(page).per(per_page)

          render json: {
            services: @services.map { |service| service_json(service) },
            meta: {
              current_page: @services.current_page,
              total_pages: @services.total_pages,
              total_count: @services.total_count,
              per_page: per_page.to_i
            }
          }, status: :ok
        end

        # GET /api/v1/stylist/services/:id
        # Show single service belonging to current stylist
        def show
          render json: {
            service: service_json(@service)
          }, status: :ok
        end

        # POST /api/v1/stylist/services
        # Create new service
        def create
          @service = Service.new(service_params)
          @service.stylist_id = current_user.id

          if @service.save
            render json: {
              service: service_json(@service),
              message: 'Service created successfully'
            }, status: :created
          else
            render json: {
              error: 'Failed to create service',
              errors: @service.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        # PATCH /api/v1/stylist/services/:id
        # Update existing service
        def update
          if @service.update(service_params)
            render json: {
              service: service_json(@service),
              message: 'Service updated successfully'
            }, status: :ok
          else
            render json: {
              error: 'Failed to update service',
              errors: @service.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        # DELETE /api/v1/stylist/services/:id
        # Soft delete: set active = false
        def destroy
          # Check if service has associated appointment add-ons
          if @service.appointment_add_ons.exists?
            render json: {
              error: 'Cannot delete service',
              message: 'This service is associated with appointments and cannot be deleted. You can deactivate it instead.'
            }, status: :unprocessable_entity
            return
          end

          # Soft delete by setting active to false
          if @service.update(active: false)
            render json: {
              message: 'Service deactivated successfully'
            }, status: :ok
          else
            render json: {
              error: 'Failed to deactivate service',
              errors: @service.errors.full_messages
            }, status: :unprocessable_entity
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

        def set_service
          @service = Service.find(params[:id])

          # Verify service belongs to current stylist
          unless @service.stylist_id == current_user.id
            render json: {
              error: 'Forbidden',
              message: 'This service does not belong to you'
            }, status: :forbidden
          end
        rescue ActiveRecord::RecordNotFound
          render json: { error: 'Service not found' }, status: :not_found
        end

        def service_params
          params.require(:service).permit(:name, :description, :price_cents, :active)
        end

        def service_json(service)
          {
            id: service.id,
            name: service.name,
            description: service.description,
            price: service.price,
            price_cents: service.price_cents,
            active: service.active,
            stylist: {
              id: current_user.id,
              name: current_user.name,
              username: current_user.username,
              location: current_user.location,
              avatar_url: current_user.avatar.attached? ? url_for(current_user.avatar) : nil
            },
            created_at: service.created_at,
            updated_at: service.updated_at,
            appointments_count: service.appointment_add_ons.count
          }
        end
      end
    end
  end
end
