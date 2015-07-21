require './config/initializers/sidekiq'
require './app/models/custom_mail'
require 'rest_client'


class TestingJob

  include Sidekiq::Worker

  def perform(url)
    @url = url
    @messages = []

    begin
      # this will return from the job if the url is already in our list
      if $redis.sismember('urls:down', @url)
        puts "[INFO] This url: #{@url} has been notify already"
        return
      end

      (ENV['FAILURE_LOOP_COUNT'] || 5).to_i.times do |iteration|
        begin
          RestClient::Request.execute(
              method: :get,
              url: @url,
              headers: {user_agent: 'Multimonitoring Testing'},
              timeout: (ENV['TIMEOUT'] || 2).to_i,
              open_timeout: 2
          )

          return
        rescue RestClient::Exception => e
          puts "[ERROR JOB] testing #{@url} this is the error #{e.http_code}:#{e.message}"
          @messages << "#{e.http_code}:#{e.message}"
        end

        sleep (ENV['TIME_BETWEEN_SAME_URL'] || 30).to_i
      end
      $redis.sadd('urls:down', @url)
      puts "[INFO] This #{@url} has been added to the down list"
      send_down_email
    rescue => e
      puts "[ERROR] Unexpected error ocurred #{e.message} #{e.backtrace}"
    end

  end

  def send_down_email
    CustomMail.send_down_email(@url,build_email_body(@messages.uniq))
    puts "[INFO] Email was send with error page report to #{ENV['EMAIL_TO']} at #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
  rescue => e
    puts "[ERROR] There was an error sending the mail #{e.message}"
  end

  def build_email_body(errors)
    str = 'Errors:'
    errors.each do |error|
      str += "#{error}\n"
    end
    str += "at #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    str
  end

end