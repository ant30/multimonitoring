web: bundle exec rackup config.ru -p $PORT
worker: bundle exec sidekiq -C ./config/sidekiq.yml -r ./config/workers.rb
