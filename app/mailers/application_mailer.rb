class ApplicationMailer < ActionMailer::Base
  default from: "ChairHop <noreply@chairhop.com>"
  layout "mailer"

  helper_method :format_datetime

  def format_datetime(time)
    time.strftime("%A, %B %-d at %-I:%M %p")
  end
end
