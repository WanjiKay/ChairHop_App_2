class StylistsController < ApplicationController
  def show
    @stylist = Stylist.find(params[:id])
    @reviews = @stylist.reviews
    @appointments = @stylist.appointments.where(booked: false)
  end
end
