class ChatsController < ApplicationController
  before_action :authenticate_user!

  rescue_from RubyLLM::ConfigurationError, with: :handle_llm_error

  private def handle_llm_error(exception)
    Rails.logger.error "LLM Error: #{exception.class}: #{exception.message}"
    respond_to do |format|
      format.html { redirect_to root_path, alert: "HOPPS is currently unavailable. Please try again later." }
      format.turbo_stream {
        render turbo_stream: turbo_stream.append(
          "messages",
          "<div class='alert alert-warning m-3'>HOPPS is currently unavailable. Please try again later.</div>"
        )
      }
    end
  end
  public

  # List all chats for the user
  def index
    skip_authorization
    @general_chats = current_user.chats.with_messages.where(appointment_id: nil).order(updated_at: :desc)
    @appointment_chats = current_user.chats.with_messages.where.not(appointment_id: nil).includes(:appointment).order(updated_at: :desc)
  end

  # Show a single chat
  def show
    @chat = current_user.chats.includes(:messages).find(params[:id])
    authorize @chat

    if Rails.env.development?
      @input_tokens = @chat.messages.pluck(:input_tokens).compact.sum
      @output_tokens = @chat.messages.pluck(:output_tokens).compact.sum
      model_info = RubyLLM.models.find(@chat.model_id)
      @context_window = model_info&.context_window
    end

    @message = Message.new
  end

  # Create a new chat
  def create
    prompt        = params[:prompt]
    chat_content  = prompt.presence || message_params[:content]
    chat_photos = Array.wrap(message_params[:photos]).reject(&:blank?)

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
      city: current_user.city.presence
    )
    authorize @chat

    if params[:appointment_id].present?
      @appointment = Appointment.find(params[:appointment_id])
      @chat.appointment = @appointment
    end

    if @chat.save
      @message = Message.new(
        content: chat_content,
        chat: @chat,
        role: "user"
      )
      if @message.save!
        chat_photos.each { |photo| @message.photos.attach(photo) } if chat_photos.present?

        if city_pending?(@chat)
          Message.create!(
            role: "assistant",
            content: "Before I help you, which city are you looking in? " \
                     "(You can save it to your profile later to skip this step)",
            chat: @chat
          )
        else
          begin
            @appointments = []
            if @chat.appointment.nil? && @message.content.present?
              begin
                embedding = RubyLLM.embed(@message.content)
                @appointments = Appointment.nearest_neighbors(
                  :embedding,
                  embedding.vectors,
                  distance: "euclidean"
                ).first(2)
              rescue RubyLLM::RateLimitError, StandardError => e
                Rails.logger.warn "HOPPS embed failed: #{e.message}"
                @appointments = Appointment.where(status: :pending)
                                           .order(created_at: :desc).limit(2)
              end
            end
            if chat_photos.present?
              @message.reload
              send_question(image_url: @message.photos.first.url)
            else
              send_question
            end
            Message.create(role: "assistant", content: @response.content, chat: @chat)
          rescue RubyLLM::ConfigurationError
            redirect_to root_path, alert: "HOPPS is currently unavailable. Please try again later."
            return
          end
        end
      else
        flash.now[:alert] = "Could not send your message. #{@message.errors.full_messages.join(', ')}"
        render :new, status: :unprocessable_entity
      end
      redirect_to chat_path(@chat)
    else
      render :new, status: :unprocessable_entity
    end
  end


  # Display form for new chat
  def new
    skip_authorization
    @chat = Chat.new
    if params[:appointment_id].present?
      @appointment = Appointment.find(params[:appointment_id])
    else
      @appointment = nil
    end
    @message = Message.new
  end

  def set_city
    @chat = current_user.chats.find(params[:id])
    authorize @chat

    city = params[:city].to_s.strip
    if city.blank?
      flash[:validation_error] = "Please enter a city to continue."
      redirect_to chat_path(@chat) and return
    end

    @chat.update!(city: city)

    @message = @chat.messages.where(role: "user").order(:created_at).first
    if @message
      begin
        if @message.photos.attached?
          @message.reload
          send_question(image_url: @message.photos.first.url)
        else
          send_question
        end
        Message.create!(role: "assistant", content: @response.content, chat: @chat)
      rescue RubyLLM::ConfigurationError
        redirect_to root_path, alert: "HOPPS is currently unavailable. Please try again later."
        return
      end
    end

    if current_user.city.blank?
      flash[:notice] = "City saved for this chat. Visit your profile to save it permanently."
    end

    redirect_to chat_path(@chat)
  end

  private
    # Strong parameters (optional, if you want to use them)
    def message_params
      params.require(:message).permit(:title, :model_id, :appointment_id, :content, photos: [])
    end

  # def process_file(file)
  #   if file.image?
  #     host = Rails.application.config.action_controller.default_url_options[:host] || "localhost:3000"
  #     image_url = Rails.application.routes.url_helpers.url_for(file, host: host)
  #     send_question(model: "gpt-4o", image_url: image_url)
  #   end
  # end

  def send_question(image_url: nil)
    model = HoppsService.new(user: current_user, chat: @chat).model(image_url: image_url)

    @ruby_llm_chat = RubyLLM.chat(model: model)

    instructions = HoppsService.new(user: current_user, chat: @chat).system_prompt

    content = @message.content.presence || "What do you see in this image?"

    @ruby_llm_chat = @ruby_llm_chat.with_instructions(instructions)

    if image_url.present?
      @response = @ruby_llm_chat.ask(content, with: { image: image_url })
    else
      @response = @ruby_llm_chat.ask(content)
    end
  end

  def city_pending?(chat)
    current_user.customer? && chat.city.blank? && current_user.city.blank?
  end

end
