class MessagesController < ApplicationController
  SYSTEM_PROMPT = "You are an assistant for a booking application.\n\nThe task is to help answer the customer's questions."
  before_action :set_chat

  def new
    @message = Message.new
  end

  def create
    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    # --------- EMBEDDING LOGIC ----------
    if @chat.appointment.nil? && params[:message][:content].present? && @chat.messages.where(role: "user").empty?
      begin
        @embedding = RubyLLM.embed(params[:message][:content])
        @appointments = Appointment.nearest_neighbors(:embedding, @embedding.vectors,
                                                      distance: "euclidean").first(2)
      rescue RubyLLM::RateLimitError => e
        Rails.logger.warn("RubyLLM rate limit exceeded: #{e.message}")
        @appointments = Appointment.where(booked: false).order(created_at: :desc).limit(2)
      rescue StandardError => e
        Rails.logger.error("Embedding error: #{e.message}")
        @appointments = Appointment.where(booked: false).order(created_at: :desc).limit(2)
      end
    else
      @appointments = []
    end

    # -------- CREATE USER MESSAGE ----------
    if @message.save
      begin
        if @message.photos.attached?
          process_file(@message.photos.first)
        else
          ask_ai_for_message
        end

        # Only create AI message if response exists
        if @response.present?
          Message.create!(
            role: "assistant",
            content: @response.content,
            chat: @chat
          )

          book_appointment(@message.content)
        end

        redirect_to chat_path(@chat)

      rescue StandardError => e
        Rails.logger.error("AI response error: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))

        @message.destroy
        @message = Message.new

        flash.now[:alert] =
          "There was an error processing your message: #{e.message}. Please try again."
        render "chats/show", status: :unprocessable_entity
      end
    else
      # Validation failed
      Rails.logger.error("Message validation failed: #{@message.errors.full_messages.join(', ')}")
      flash.now[:alert] = @message.errors.full_messages.join(", ")

      render "chats/show", status: :unprocessable_entity
    end
  end

  # ------------------------------------------------------
  # IMAGE HANDLING — now uses RubyLLM .with_image(url: ...)
  # ------------------------------------------------------
  def process_file(attachment)
    return unless attachment.image?

    host = Rails.application.config.action_controller.default_url_options[:host] || "localhost:3000"
    image_url = Rails.application.routes.url_helpers.url_for(attachment, host: host)

    ask_ai_for_message(model: "gpt-4o", image_url: image_url)
  end

  # ------------------------------------------------------
  # MAIN AI FUNCTION — PATCHED FOR RUBYLLM 1.6.4
  # ------------------------------------------------------
  def ask_ai_for_message(model: "gpt-4.1-nano", image_url: nil)
    model = "gpt-4o" if image_url.present?

    chat = RubyLLM.chat(model: model)

    # Build instructions
    base_instructions =
      if @chat.appointment.nil?
        instruction_without_appointment +
          @appointments.map { |a| appointment_prompt(a) }.join("\n\n")
      else
        instruction_with_appointment
      end

    instructions = base_instructions + conversation_history

    # Build user text
    user_text = @message.content.presence || "What do you see in this image?"

    # Apply instructions and image
    chat = chat.with_instructions(instructions)
    chat = chat.with_image(url: image_url) if image_url.present?

    # Ask AI
    @response = chat.ask(user_text)
  end

  # ------------------------------------------------------
  # BOOKING HELPER
  # ------------------------------------------------------
  def book_appointment(message_content)
    appointment = @chat.appointment
    return if appointment.nil?

    text = message_content.downcase

    if text.include?("book") || text.include?("reserve")
      if appointment.booked?
        Message.create(role: "assistant", content: "That chair is already taken.", chat: @chat)
      else
        appointment.update(booked: true, user: @chat.user)
        Message.create(
          role: "assistant",
          content: "✅ You're all set! I've booked your seat at #{appointment.location} with #{appointment.stylist.name}.",
          chat: @chat
        )
      end
    end
  end

  private

  def set_chat
    @chat = Chat.find(params[:chat_id])
  end

  def message_params
    params.require(:message).permit(:content, photos: [])
  end

  def instruction_without_appointment
    "You are a helpful assistant. The user might ask about booking an appointment. " \
    "Provide information about available appointments and assist with the booking process."
  end

  def instruction_with_appointment
    "You are a helpful assistant. The user is asking about their appointment. " \
    "Provide details about the appointment and assist with any changes or cancellations.\n\n" +
    appointment_context
  end

  def appointment_context
    return "" if @chat.appointment.nil?
    appointment = @chat.appointment

    <<~CONTEXT
      Here is the appointment information:
      - Time: #{appointment.time&.strftime('%A, %B %d, %Y at %H:%M')}
      - Location: #{appointment.location}
      - Salon: #{appointment.salon}
      - Stylist: #{appointment.stylist&.name}
      - Selected Service: #{appointment.selected_service}
      - Available Services: #{appointment.services}
      - Status: #{appointment.status}

      Always use ONLY this information when answering questions about the appointment.
      Never invent or guess appointment details.
    CONTEXT
  end

  def appointment_prompt(appointment)
    if appointment.booked?
      "Appointment on #{appointment.time&.strftime('%B %d, %Y at %H:%M')} is booked."
    else
      "Available appointment on #{appointment.time&.strftime('%B %d, %Y at %H:%M')}."
    end
  end

  def conversation_history
    previous = @chat.messages.order(:created_at)
    return "" if previous.empty?

    history = previous.map do |m|
      role = m.role == "user" ? "Customer" : "Assistant"
      "#{role}: #{m.content}"
    end.join("\n\n")

    "\n\n--- Conversation so far ---\n#{history}\n--- End of conversation ---\n\nContinue the conversation naturally. Remember what appointments were offered."
  end
end
