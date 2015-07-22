require 'pony'

class CustomMail

  def initialize
    @from = ENV['EMAIL_FROM']
    @to = ENV['EMAIL_TO']
    @subject_prefix = "#{ENV['EMAIL_SUBJECT_PREFIX']}"
    @address = ENV['MAILGUN_SMTP_SERVER']
    @port = ENV['MAILGUN_SMTP_PORT']
    @user_name = ENV['MAILGUN_SMTP_LOGIN']
    @password = ENV['MAILGUN_SMTP_PASSWORD']
    @authentication = :login
    @domain = ENV['EMAIL_DOMAIN']
  end

  def self.send_up_email(url, body)
    send("#{url} is up",
         body)
  end

  def self.send_down_email(url, body)
    send("#{url} id down",
         body)
  end

  def send(subject, body)
    Pony.mail({
      from: @from,
      to: @to,
      subject: "#{@subject_prefix} - #{subject}",
      body: body,
      via: :smtp,
      via_options: {
          :address => @address,
          :port => @port,
          :enable_starttls_auto => true,
          :user_name => @user_name,
          :password => @password,
          :authentication => @authentication,
          :domain => @domain
      }
    })
  end
end
