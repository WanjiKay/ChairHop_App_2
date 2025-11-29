SYSTEM_PROMPT = "You are an assistant for a booking application. n/n/ The task is to help answer the questions of the customers."

class MessagesController < ApplicationController
  before_action :set_chat

  def new
    @message = Message.new
  end

  def create
    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "User"
    @embedding = RubyLLM.embed(params[:message][:content])
    @appointments = Appointment.nearest_neighbors(:embedding, @embedding.vectors, distance: "euclidean").first(2)
    if @message.save
      if @message.photos.attached?
        process_file(@message.photos.first)
      else
        send_question
      end
      Message.create(role: "assistant", content: @response.content, chat: @chat)
      book_appointment(@message.content)
      redirect_to chat_path(@chat)
    else
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
    Never invnt new appointments, locations, times, stylists, or services. \
    Never show appointments from earler messages unless the user explicitly refers to them. \
    When the user selects an option (e.g. I want #1) lock in that appointment and do not show any other options. \
    If the user picks a service from a multi-service appointment, do not ask for more services. Confirm the exact service they chose and proceed toward booking. \
    When the useer says they want to book, provide only the check-in link for their chosen appointment, formatted as a markdown clickable link: [Check in here] (URL). \
    Always keep the conversation context and continue where the user left off. Neer restart the search unless the user exp;icitly asks for ne times, dates, locations, or if the times and dates have already passed. \
    Here are the nearest appointment available based on the user's question: "
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
