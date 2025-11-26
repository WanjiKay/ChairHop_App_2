class StylistsController < ApplicationController
  def show
    @stylist = User.find(params[:id])
    @reviews = @stylist.reviews_for_stylist
    @appointments = @stylist.appointments_as_stylist.where(booked: false)
  end
end
