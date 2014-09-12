require "heroku-api"

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
end
