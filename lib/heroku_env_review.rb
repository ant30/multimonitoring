require 'logger'
require 'heroku-api'
require 'rest-client'
require 'yaml'

require './app/models/custom_mail'


class HerokuEnvReview

  def initialize
    @heroku = Heroku::API.new(:api_key => ENV['HEROKU_API_KEY'])
    @email_report = ENV['HEROKU_SHARED_ENV_EMAIL_REPORT'] == 'true'
    @propagate_change = ENV['HEROKU_SHARED_ENV_PROPAGE_CHANGES'] == 'true'
    @settings = get_settings
    @log = Logger.new(STDOUT)
  end

  def review_all_apps
    report = @settings.map do |app, _|
      @log.info "Reviewing env vars shared from #{app}"
      review_app(app)
    end.select { |item| item != nil }
    send_report(report) if @email_report
  end


  def review_app_shared_env_vars(app)
    report = review_app(app)
    send_report(report) if @email_report
  end

  private

  def get_settings
    response =  RestClient.get(ENV['HEROKU_SHARED_ENV_FILE']) do |resp, _, _|
      if resp.code == 200
        resp
      else
        raise "[ERROR] Failed to load the remote file heroku env config. Response status: #{response.code}"
      end
    end
    YAML.load(response.body)
  end

  def review_env_var(app, env_var)
    var_value = get_app_env_var(app, env_var)
    message_action = @propagate_change ? "CHANGED" : "ALERT"
    @settings[app][env_var].map do |target_app, target_var_name|
      if var_value != get_app_env_var(target_app, target_var_name)
        message =  "ENV VAR #{message_action}: Value for #{target_var_name} in #{target_app} is not equal to #{env_var} in #{app}"
        @heroku.put_config_vars(target_app, target_var_name => var_value) if @propagate_change
        @log.alert message
        message
      end
    end.select { |item| item != nil }
  end

  def review_app(app)
    @settings[app].map do |env_var, _|
      @log.info "Reviewing env var #{env_var} for #{app}"
      review_env_var(app, env_var)
    end.select { |item| item != nil }
  end

  def get_app_env_var(app, env_var)
    @heroku.get_config_vars(app).body[env_var]
  end

  def send_report(report)
    header = @propagate_change ? "The change was propagated, please review it" : "The change was NOT propagated, please, review it"
    mailer = CustomMail.new
    mailer.send(
      "ALERT: Heroku Shared ENV VAR changed",
      "#{header} \r\r#{report.join('\r')} \r"
    )
  end

end
