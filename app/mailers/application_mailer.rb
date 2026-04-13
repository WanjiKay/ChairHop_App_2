class ApplicationMailer < ActionMailer::Base
  default from: "ChairHop <notifications@chair-hop.com>",
          reply_to: "noreply@chair-hop.com"
  layout "mailer"

  helper_method :format_datetime

  def format_datetime(time)
    time.strftime("%A, %B %-d at %-I:%M %p")
  end
end
