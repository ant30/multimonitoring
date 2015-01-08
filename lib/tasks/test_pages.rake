require 'pony'
require 'rest_client'

namespace :test_pages do
  desc 'test status code for multiple pages'
  task 'test_pages' do
    errors_url = []

    response =  RestClient.get(ENV['AMAZON_LANDING_PAGE_LIST']) do |response, request, result|
      if response.code == 200
        response
      else
        raise "Fail to load fail from amazon #{response.code}"
      end
    end

    urls = response.body.split(/\n/)
    urls.each do |url|
      begin
        RestClient::Request.execute(
          method: :get,
          url: url,
          headers: {user_agent: 'Multimonitoring Testing'},
          timeout: 2,
          open_timeout: 2
        )
      rescue
        puts "this #{url} has some problems"
        errors_url << url
      end
      sleep 1
    end

    if errors_url.size > 0
      Pony.mail({
          from: ENV['EMAIL_FROM'] ,
          to: ENV['EMAIL_TO'],
          subject: "#{ENV['EMAIL_SUBJECT_PREFIX']} Landing Pages Failing",
          body: "This Landing Pages are down #{errors_url.join("\n")} at #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}",
          via: :smtp,
          via_options: {
              :address => ENV['MAILGUN_SMTP_SERVER'],
              :port => ENV['MAILGUN_SMTP_PORT'],
              :enable_starttls_auto => true,
              :user_name => ENV['MAILGUN_SMTP_LOGIN'],
              :password => ENV['MAILGUN_SMTP_PASSWORD'],
              :authentication => :login,
              :domain => ENV['EMAIL_DOMAIN'],
          }
      })
    end
  end
end

