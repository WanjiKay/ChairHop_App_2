class ChatsController < ApplicationController
  before_action :authenticate_user!

  # List all chats for the user
  def index
    if params[:appointment_id].present?
      @appointment = Appointment.find(params[:appointment_id])
      @chats = current_user.chats.where(appointment: @appointment)
    else
      @chats = current_user.chats.where(appointment: nil)
    end
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

    @chat = Chat.new(
      title: "New Chat",
      model_id: "gpt-4.1-nano",
      customer: current_user,
    )

    if @chat.save
      @message = Message.new(
        content: chat_content,
        chat: @chat,
        role: "User"
      )

    # Attach photos correctly
      if chat_photos.present?
        @message.photos.attach(chat_photos)
      end

    # Embeddings
      @embedding = RubyLLM.embed(@message.content)
      @appointments = Appointment.nearest_neighbors(
        :embedding,
        @embedding.vectors,
        distance: "euclidean"
      ).first(2)

      if @message.save
        if @message.photos.attached?
          process_file(@message.photos.first)
        else
          send_question
        end

        Message.create(
          role: "assistant",
          content: @response.content,
          chat: @chat
        )

        redirect_to chat_path(@chat)
      else
        flash.now[:alert] = "Could not send your message."
        render :new, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "Failed to create chat."
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
end
