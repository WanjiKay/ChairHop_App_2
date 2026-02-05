class PushNotificationService
  def initialize
    @client = Exponent::Push::Client.new
  end

  # Send notification to a single user
  def send_to_user(user, title, body, data = {})
    return unless user.push_token.present?

    message = {
      to: user.push_token,
      sound: 'default',
      title: title,
      body: body,
      data: data
    }

    begin
      @client.send_messages([message])
    rescue => e
      Rails.logger.error "Push notification error: #{e.message}"
    end
  end

  # Send notification to multiple users
  def send_to_users(users, title, body, data = {})
    tokens = users.map(&:push_token).compact
    return if tokens.empty?

    messages = tokens.map do |token|
      {
        to: token,
        sound: 'default',
        title: title,
        body: body,
        data: data
      }
    end

    begin
      @client.send_messages(messages)
    rescue => e
      Rails.logger.error "Push notification error: #{e.message}"
    end
  end
end
