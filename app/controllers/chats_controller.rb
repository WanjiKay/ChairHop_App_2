class ChatsController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:appointment_id].present?
      @appointment = Appointment.find(params[:appointment_id])
      @chats = current_user.chats.where(appointment: @appointment)
    else
      @chats = current_user.chats.where(appointment: nil)
    end
  end

  def show
    @chat = Chat.includes(:messages).find(params[:id])
    if Rails.env.development?
      @input_tokens = @chat.messages.pluch(:input_tokens).compact.sum
      @output_tokens = @chat.messages.pluck(:output_tokens).compact.sum
      @context_window = RubyLLM.models.find(@chat.model_id).context_window
    end
    @message = Message.new
  end

  def create
    @appointment_id = params.dig(:chat, :appointment_id) || params[:appointment_id]
    if appointment_id.present?
      @appointment = Appointment.find(appointment_id)
    else
      @appointment = Appointment.find_by(appointment.stylist.name: "General Chat")
    end
    @chat = Chat.new(title: "Untitled", model_id: "gpt-4.1-nano")
    @chat.user = current_user
    @chat.appointment = @appointment
    if @chat.save
      redirect_to @chat
    else
      flash.now[:alert] = "Failed to create chat."
      render :new, status: :unprocessable_entity
    end
  end

  def new
    @chat = Chat.new
    if params[:appointment_id].present?
      @appointment = Appointment.find(params[:appointment_id])
    else
      @appointment = nil
    end
  end

  private


end
