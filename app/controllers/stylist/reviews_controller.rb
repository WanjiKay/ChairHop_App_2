class Stylist::ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_stylist!

  def index
    skip_authorization
    @reviews = Review.joins(:appointment)
      .where(appointments: { stylist_id: current_user.id })
      .includes(:customer, :appointment, photos_attachments: :blob)
      .order(created_at: :desc)
  end

  private

  def ensure_stylist!
    redirect_to root_path, alert: "Access denied." unless current_user.stylist?
  end
end
