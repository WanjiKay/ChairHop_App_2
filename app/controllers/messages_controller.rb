class MessagesController < ApplicationController
  before_action :set_chat

  def new
    skip_authorization
    @message = Message.new
  end

  def create
    skip_authorization

    # Guard: prevent AI response if city is still pending for this chat
    if @chat.city.blank? && current_user.city.blank? && current_user.customer?
      flash[:validation_error] = "Please provide your city first."
      redirect_to chat_path(@chat) and return
    end

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
        @appointments = Appointment.where(status: :pending).order(created_at: :desc).limit(2)
      rescue StandardError => e
        Rails.logger.error("Embedding error: #{e.message}")
        @appointments = Appointment.where(status: :pending).order(created_at: :desc).limit(2)
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
      flash.now[:validation_error] = @message.errors.full_messages.join(", ")

      render "chats/show", status: :unprocessable_entity
    end
  end

  # ------------------------------------------------------
  # IMAGE HANDLING — now uses RubyLLM .with_image(url: ...)
  # ------------------------------------------------------
  def process_file(attachment)
    return unless attachment.image?

    image_url = attachment.url
    ask_ai_for_message(image_url: image_url)
  end

  # ------------------------------------------------------
  # MAIN AI FUNCTION — PATCHED FOR RUBYLLM 1.6.4
  # ------------------------------------------------------
  def ask_ai_for_message(image_url: nil)
    model = HoppsService.new(user: current_user, chat: @chat).model(image_url: image_url)

    chat = RubyLLM.chat(model: model)

    instructions = HoppsService.new(user: current_user, chat: @chat).system_prompt + conversation_history

    # Build user text
    user_text = @message.content.presence || "What do you see in this image?"

    # Apply instructions
    chat = chat.with_instructions(instructions)

    # Ask AI (with image if present)
    if image_url.present?
      @response = chat.ask(user_text, with: { image: image_url })
    else
      @response = chat.ask(user_text)
    end
  end

  # TODO: wire up or remove
  def suggest_stylist(stylist_id)
    stylist = User.where(role: :stylist).find_by(id: stylist_id)
    return "I couldn't find that stylist." unless stylist

    url = stylist_url(stylist)
    "I'd recommend booking with #{stylist.name}. [View their booking page](#{url})"
  end

  private

  def set_chat
    @chat = current_user.chats.find(params[:chat_id])
  end

  def message_params
    params.require(:message).permit(:content, photos: [])
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
