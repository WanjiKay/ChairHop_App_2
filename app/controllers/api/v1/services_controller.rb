module Api
  module V1
    class ServicesController < BaseController
      skip_before_action :authenticate_api_user!, only: [:index, :show]
      before_action :set_service, only: [:show]

      # GET /api/v1/services
      # List all active services (public browsing)
      def index
        @services = Service.includes(:stylist)

        # Filter by stylist if provided
        if params[:stylist_id].present?
          @services = @services.where(stylist_id: params[:stylist_id])
        end

        # Filter by active status (default: true)
        active_filter = params[:active].present? ? params[:active] == 'true' : true
        @services = @services.where(active: active_filter)

        # Order by name
        @services = @services.order(name: :asc)

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

      # GET /api/v1/services/:id
      # Show single service details
      def show
        render json: {
          service: service_json(@service)
        }, status: :ok
      end

      private

      def set_service
        @service = Service.includes(:stylist).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Service not found' }, status: :not_found
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
            id: service.stylist.id,
            name: service.stylist.name,
            username: service.stylist.username,
            location: service.stylist.location,
            avatar_url: service.stylist.avatar.attached? ? url_for(service.stylist.avatar) : nil
          },
          created_at: service.created_at,
          updated_at: service.updated_at
        }
      end
    end
  end
end
