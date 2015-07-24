require "heroku-api"
require './lib/heroku_env_review'

namespace :heroku do
  desc "Restart specified heroku app"
  task :restart_app, [:app] do |t,args|
    puts "#{args.app}"
    if args.app == nil
        abort("Please, the app name is required")
    end
    if ENV['HEROKU_API_KEY'] == nil
        abort("Please, set env var HEROKU_API_KEY properly")
    end
    heroku = Heroku::API.new(:api_key => ENV['HEROKU_API_KEY'])
    heroku.post_ps_restart(args.app)
  end

  desc "Review shared env vars for one heroku app"
  task :review_shared_env_app, [:app] do |_,args|
    abort("Please, the app name is required") if args.app == nil
    abort("Please, set env var HEROKU_API_KEY properly") if ENV['HEROKU_API_KEY'] == nil
    abort("Please, set env var HEROKU_SHARED_ENV_FILE properly") if ENV['HEROKU_SHARED_ENV_FILE'] == nil

    reviewer = HerokuEnvReview.new
    reviewer.review_app_shared_env_vars(args.app)

  end

  desc "Review shared env vars for all heroku apps in config file"
  task :review_shared_env_all_apps do
    abort("Please, set env var HEROKU_API_KEY properly") if ENV['HEROKU_API_KEY'] == nil
    abort("Please, set env var HEROKU_SHARED_ENV_FILE properly") if ENV['HEROKU_SHARED_ENV_FILE'] == nil

    reviewer = HerokuEnvReview.new
    reviewer.review_all_apps
  end

  desc "Review shared env vars for all heroku apps in config file without notifications or action"
  task :review_shared_env_all_apps_dryrun do
    abort("Please, set env var HEROKU_API_KEY properly") if ENV['HEROKU_API_KEY'] == nil
    abort("Please, set env var HEROKU_SHARED_ENV_FILE properly") if ENV['HEROKU_SHARED_ENV_FILE'] == nil

    reviewer = HerokuEnvReview.new
    reviewer.review_all_apps_dryrun
  end
end
