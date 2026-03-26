class StylistsController < ApplicationController
  def index
    @stylists = User.where(role: :stylist)

    # Search by name, location, or address fields
    if params[:search].present?
      term = "%#{params[:search]}%"
      @stylists = @stylists.where(
        "name ILIKE ? OR location ILIKE ? OR city ILIKE ? OR state ILIKE ? OR zip_code ILIKE ?",
        term, term, term, term, term
      )
    end

    # Filter by service
    if params[:service].present?
      @stylists = @stylists.joins(:services).where(services: { name: params[:service] }).distinct
    end

    @stylists = @stylists.order(:name)
  end

  def show
    @stylist = User.find(params[:id])
    @reviews = @stylist.reviews_for_stylist
    @appointments = @stylist.appointments_as_stylist.where(booked: false)
  end
end
