SYSTEM_PROMPT = "You are an assistant for a booking application. n/n/ The task is to help answer the questions of the customers."

class MessagesController < ApplicationController
  before_action :set_chat

  def new
    @message = Message.new
  end

  def create
    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    # Handle embedding with error handling - only for general chats without appointments
    if @chat.appointment.nil?
      begin
        @embedding = RubyLLM.embed(params[:message][:content])
        @appointments = Appointment.nearest_neighbors(:embedding, @embedding.vectors, distance: "euclidean").first(2)
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

    if @message.save
      begin
        if @message.photos.attached?
          process_file(@message.photos.first)
        else
          send_question
        end
        Message.create(role: "assistant", content: @response.content, chat: @chat)
        book_appointment(@message.content)
        redirect_to chat_path(@chat)
      rescue StandardError => e
        Rails.logger.error("AI response error: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
        @message.destroy # Remove the saved user message since we couldn't get a response
        @message = Message.new # Create a fresh message instance for the form

        # Load development mode tokens if needed
        if Rails.env.development? && @chat.model_id.present?
          @input_tokens = @chat.messages.pluck(:input_tokens).compact.sum
          @output_tokens = @chat.messages.pluck(:output_tokens).compact.sum
          begin
            @context_window = RubyLLM.models.find(@chat.model_id).context_window
          rescue
            @context_window = nil
          end
        end

        flash.now[:alert] = "There was an error processing your message: #{e.message}. Please try again."
        render "chats/show", status: :unprocessable_entity
      end
    else
      # Log validation errors for debugging
      Rails.logger.error("Message validation failed: #{@message.errors.full_messages.join(', ')}")

      flash.now[:alert] = @message.errors.full_messages.join(", ")

      # Load development mode tokens if needed
      if Rails.env.development? && @chat.model_id.present?
        @input_tokens = @chat.messages.pluck(:input_tokens).compact.sum
        @output_tokens = @chat.messages.pluck(:output_tokens).compact.sum
        begin
          @context_window = RubyLLM.models.find(@chat.model_id).context_window
        rescue
          @context_window = nil
        end
      end

      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def book_appointment(message_content)
    appointment = @chat.appointment
    return if appointment.nil?
    content = message_content.downcase

    if content.include?("book") || content.include?("reserve")
      if appointment.booked?
        Message.create(role: "assistant", content: "That chair is already taken.", chat: @chat)
      else
        appointment.update(booked: true, user: @chat.user)
        Message.create(role: "assistant", content: "✅ You’re all set! I’ve booked your seat at #{appointment.location} with #{appointment.stylist.name}.", chat: @chat)
      end
    end
  end

  def brodact_mesage(message)
    Turbo::StreamsChannel.broadcast_replace_to(@chat, target: helpers.dom_id(message), partial: "messages/message", locals: {message: message})
  end

  def process_file(file)
    if file.image?
      send_question(model: "gpt-4o", with: { image: @message.photos.first.url })
    end
  end

  def send_question(model: "gpt-4.1-nano", with: {})
    @ruby_llm_chat = RubyLLM.chat(model: model)
    if @chat.appointment.nil?
      instructions = instruction_without_appointment
      instructions += @appointments.map { |appointment| appointment_prompt(appointment) }.join("\n\n")
    else
      instructions = instruction_with_appointment
    end
    @response = @ruby_llm_chat.with_instructions(instructions).ask(@message.content, with: with)
  end

  def set_chat
    @chat= Chat.find(params[:chat_id])
  end

  def message_params
    params.require(:message).permit(:content, photos: [])
  end

  def appointment_context
    return if @chat.appointment.nil?
    appointment = @chat.appointment
    "Here is the context of the appointment: #{appointment.content}, #{appointment.time}, the location is: #{appointment.location}, the stylist's name is: #{appointment.stylist.name}."
  end

  def instruction_with_appointment
    [SYSTEM_PROMPT, appointment_context]
    .compact.join("\n\n")
  end

  def instruction_without_appointment
    [SYSTEM_PROMPT, chat_context_without_appointment]
    .compact.join("\n\n")
  end

  def chat_context_without_appointment
    "You are an assistant for an appointment booking app. \
    Your task is to help the user pick and book an appointment from the options provided. \

    Only use the appointment list provided to you for this turn. \
    Never invent new appointments, locations, times, stylists, or services. \
    Never show appointments from earlier messages unless the user explicitly refers to them. \

    When the user selects an option (e.g. “I want #1”, “the first one”, “the 20:53 appointment”),
    lock in that appointment and do not show any other options for the rest of the conversation
    unless the user explicitly requests a different appointment. \

    If the appointment contains multiple services and the user chooses one or multiple services,
    do not ask for more services. \
    Confirm exactly the service(s) they chose and continue toward booking. \
    Allow the user to book ANY combination of services listed in the appointment. \

    When the user says they want to book (e.g. “yes”, “book it”, “confirm”, “I want this one”),
    provide only the check-in link for their chosen appointment, formatted as a clickable markdown link:
    Check in here. \

    Do not return to the appointment search stage after the user selects an appointment. \
    Do not introduce new appointments after the user has made a selection. \
    Do not replace the user's chosen appointment with a different one. \

    Always keep the conversation context and continue where the user left off. \
    Never restart the search unless the user explicitly asks for new times, dates, locations,
    or if the previously provided appointments are no longer valid. \

    Here are the nearest appointments available based on the user's question:"
  end

  def appointment_prompt(appointment)
    "APPOINTMENT id: #{appointment.id},
    time: #{appointment.time},
    location: #{appointment.location},
    stylist: #{appointment.stylist.name},
    salon: #{appointment.salon},
    services: #{appointment.services},
    url: #{check_in_appointment_url(appointment)}"
  end

end
