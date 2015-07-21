require 'rest_client'
require './config/initializers/sidekiq'
require './app/workers/testing_job'
require './app/models/custom_mail'

namespace :test_pages do
  desc 'test status code for multiple pages'
  task 'test_pages' do
    puts '[INFO] Starting to Test Pages'
    response =  RestClient.get(ENV['URL_TO_TESTED_URLS']) do |resp, _, _|
      if resp.code == 200
        resp
      else
        raise "[ERROR] Fail to load the remote file. Response status: #{response.code}"
      end
    end
    urls = response.body.split(/\n/)
    urls.each do |url|
      check_url(url) do
        RestClient::Request.execute(
            method: :get,
            url: url,
            headers: {user_agent: 'Multimonitoring Testing'},
            timeout: (ENV['TIMEOUT'] || 2).to_i,
            open_timeout: 2
        )
        check_for_up_email(url)
      end
      sleep (ENV['TIME_BETWEEN_DIFFERENT_URL'] ||1).to_i
    end
  end
end

def check_url(url)
  yield
rescue RestClient::Exception => e
  puts "[ERROR] This #{url} has some problems #{e.http_code}:#{e.message}"
  TestingJob.perform_in((ENV['TIME_BEFORE_JOB'] || 2).to_i, url)
end

def check_for_up_email(url)
  # check if the url was down and now is fixed
  if $redis.sismember('urls:down', url)
    $redis.srem('urls:down', url)
    puts "[INFO] #{url} has been fixed ALELUYA!!!!!!!!!"
    begin
      CustomMail.send_up_email(url)
      puts "[INFO] Email was sent with up page report to #{ENV['EMAIL_TO']} at #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    rescue => e
      puts "[ERROR] There was an error sending the mail #{e.message}"
    end
  end
end

