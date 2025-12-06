class ConversationsController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:appointment_id].present?
      @appointment = Appointment.find(params[:appointment_id])
      @conversations = Conversation.where(appointment: @appointment)
                                   .where("customer_id = ? OR stylist_id = ?", current_user.id, current_user.id)
    else
      # Load all conversations where the user is either customer or stylist
      # Separate into conversations as customer and as stylist
      @conversations_as_customer = Conversation.where(customer_id: current_user.id)
                                               .includes(:stylist, :appointment, :conversation_messages)
                                               .order(updated_at: :desc)

      @conversations_as_stylist = Conversation.where(stylist_id: current_user.id)
                                              .includes(:customer, :appointment, :conversation_messages)
                                              .order(updated_at: :desc)

      @conversations = Conversation.where("customer_id = ? OR stylist_id = ?", current_user.id, current_user.id)
                                   .includes(:customer, :stylist, :appointment, :conversation_messages)
                                   .order(updated_at: :desc)
    end
  end

  def show
    @conversation = Conversation.includes(:conversation_messages).find(params[:id])
    authorize_conversation_access!
    @conversation_message = ConversationMessage.new
  end

  def new
    @conversation = Conversation.new
    if params[:appointment_id].present?
      @appointment = Appointment.find(params[:appointment_id])
    else
      @appointment = nil
    end
  end

  def create
    @appointment_id = params.dig(:conversation, :appointment_id) || params[:appointment_id]

    if @appointment_id.blank?
      flash[:alert] = "Appointment is required to create a conversation."
      redirect_to appointments_path and return
    end

    @appointment = Appointment.find(@appointment_id)

    # Check if conversation already exists for this appointment
    @conversation = Conversation.find_by(appointment: @appointment)

    if @conversation
      redirect_to @conversation
    else
      @conversation = Conversation.new
      @conversation.appointment = @appointment
      # Customer is the current user who wants to message the stylist
      @conversation.customer = current_user
      @conversation.stylist = @appointment.stylist

      if @conversation.save
        redirect_to @conversation
      else
        flash.now[:alert] = "Failed to create conversation."
        render :new, status: :unprocessable_entity
      end
    end
  end

  private

  def authorize_conversation_access!
    unless @conversation.customer_id == current_user.id || @conversation.stylist_id == current_user.id
      redirect_to root_path, alert: "You don't have access to this conversation."
    end
  end
end
