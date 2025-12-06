class ChatsController < ApplicationController
  SYSTEM_PROMPT = "You are an assistant for a booking application. n/n/ The task is to help answer the questions of the customers."
  before_action :authenticate_user!

  # List all chats for the user
  def index
    @general_chats = current_user.chats.with_messages.where(appointment_id: nil).order(updated_at: :desc)
    @appointment_chats = current_user.chats.with_messages.where.not(appointment_id: nil).includes(:appointment).order(updated_at: :desc)
  end

  # Show a single chat
  def show
    @chat = Chat.includes(:messages).find(params[:id])

    if Rails.env.development?
      @input_tokens = @chat.messages.pluck(:input_tokens).compact.sum
      @output_tokens = @chat.messages.pluck(:output_tokens).compact.sum
      @context_window = RubyLLM.models.find(@chat.model_id).context_window
    end

    @message = Message.new
  end

  # Create a new chat
  def create
    prompt        = params[:prompt]
    chat_content  = prompt.presence || params.dig(:chat, :content)
    chat_photos   = params.dig(:chat, :photos)

    # Validate that content is present before creating chat
    if chat_content.blank? && chat_photos.blank?
      flash.now[:alert] = "Please enter a message or upload an image."
      @chat = Chat.new
      if params[:appointment_id].present?
        @appointment = Appointment.find(params[:appointment_id])
      end
      render :new, status: :unprocessable_entity
      return
    end

    # Flag to track if we've already rendered/redirected
    @already_rendered = false

    # Use transaction to ensure chat is only saved if message is saved successfully
    ActiveRecord::Base.transaction do
      # Use first message content as title (truncated to 50 characters)
      chat_title = if chat_content.present?
        chat_content.truncate(50, separator: ' ', omission: '...')
      elsif chat_photos.present?
        "Image upload"
      else
        "New Chat"
      end

      @chat = Chat.new(
        title: chat_title,
        model_id: "gpt-4.1-nano",
        customer: current_user,
      )

      if params[:appointment_id].present?
        @appointment = Appointment.find(params[:appointment_id])
        @chat.appointment = @appointment
      end

      unless @chat.save
        flash.now[:alert] = "Failed to create chat."
        @already_rendered = true
        render :new, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end

      @message = Message.new(
        content: chat_content,
        chat: @chat,
        role: "user"
      )

      # Attach photos correctly
      if chat_photos.present?
        @message.photos.attach(chat_photos)
      end

      # Embeddings - only for general chats without appointments
      if @chat.appointment.nil?
        begin
          @embedding = RubyLLM.embed(@message.content)
          @appointments = Appointment.nearest_neighbors(
            :embedding,
            @embedding.vectors,
            distance: "euclidean"
          ).first(2)
        rescue RubyLLM::RateLimitError => e
          # Fallback to recent appointments when rate limit is hit
          Rails.logger.warn("RubyLLM rate limit exceeded: #{e.message}")
          @appointments = Appointment.where(booked: false)
                                     .order(created_at: :desc)
                                     .limit(2)
          flash[:notice] = "AI search temporarily unavailable (rate limit). Showing recent appointments."
        rescue StandardError => e
          # Handle any other embedding errors
          Rails.logger.error("Embedding error: #{e.message}")
          @appointments = Appointment.where(booked: false)
                                     .order(created_at: :desc)
                                     .limit(2)
        end
      else
        @appointments = []
      end

      unless @message.save
        flash.now[:alert] = "Could not send your message. #{@message.errors.full_messages.join(', ')}"
        @already_rendered = true
        render :new, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end

      # Only proceed with AI response if message was saved successfully
      begin
        if @message.photos.attached?
          process_file(@message.photos.first)
        else
          send_question
        end

        Message.create!(
          role: "assistant",
          content: @response.content,
          chat: @chat
        )
      rescue StandardError => e
        Rails.logger.error("AI response error: #{e.message}")
        flash.now[:alert] = "Failed to get AI response. Please try again."
        @chat = Chat.new(title: chat_title)
        if params[:appointment_id].present?
          @appointment = Appointment.find(params[:appointment_id])
        end
        @already_rendered = true
        render :new, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end

    # Only redirect if we successfully created everything and haven't already rendered
    return if @already_rendered

    if @chat.persisted?
      redirect_to chat_path(@chat)
    else
      # If transaction was rolled back, re-render the form
      @chat ||= Chat.new
      if params[:appointment_id].present?
        @appointment ||= Appointment.find(params[:appointment_id])
      end
      render :new, status: :unprocessable_entity
    end
  end


  # Display form for new chat
  def new
    @chat = Chat.new
    if params[:appointment_id].present?
      @appointment = Appointment.find(params[:appointment_id])
    else
      @appointment = nil
    end
  end

  private
    # Strong parameters (optional, if you want to use them)
    def chat_params
      params.require(:chat).permit(:title, :model_id, :appointment_id, :content, photos: [])
    end

    def process_file(file)
      if file.image?
        # Get the direct Cloudinary URL (publicly accessible, not a redirect)
        image_url = file.service_url
        send_question(model: "gpt-4o", with: { image: image_url })
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

  def instruction_without_appointment
    [SYSTEM_PROMPT, chat_context_without_appointment]
    .compact.join("\n\n")
  end

  def chat_context_without_appointment
    "You are an assistant for an appointment booking app. \
    Your task is to help the user pick and book an appointment from the options provided. \
\
    Only use the appointment list provided to you for this turn. \
    Never invent new appointments, locations, times, stylists, or services. \
    Never show appointments from earlier messages unless the user explicitly refers to them. \
\
    When presenting appointments, format each one clearly with: \
    - The appointment number/ID \
    - Time, location, salon, and stylist name \
    - Services available \
    - A clickable link using this format: [View Appointment](URL) \
\
    When the user selects an option (e.g. 'I want #1', 'the first one', 'the 20:53 appointment'), \
    lock in that appointment and do not show any other options for the rest of the conversation \
    unless the user explicitly requests a different appointment. \
\
    If the appointment contains multiple services and the user chooses one or multiple services, \
    do not ask for more services. \
    Confirm exactly the service(s) they chose and continue toward booking. \
    Allow the user to book ANY combination of services listed in the appointment. \
\
    When the user says they want to book (e.g. 'yes', 'book it', 'confirm', 'I want this one'), \
    provide the check-in link for their chosen appointment as a clickable markdown link: \
    [Check in for your appointment](URL) \
\
    Do not return to the appointment search stage after the user selects an appointment. \
    Do not introduce new appointments after the user has made a selection. \
    Do not replace the user's chosen appointment with a different one. \
\
    Always keep the conversation context and continue where the user left off. \
    Never restart the search unless the user explicitly asks for new times, dates, locations, \
    or if the previously provided appointments are no longer valid. \
\
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

  def instruction_with_appointment
    [SYSTEM_PROMPT, appointment_context]
    .compact.join("\n\n")
  end

  def appointment_context
    return if @chat.appointment.nil?
    appointment = @chat.appointment
    "Here is the context of the appointment: #{appointment.content}, #{appointment.time}, the location is: #{appointment.location}, the stylist's name is: #{appointment.stylist.name}."
  end

end
