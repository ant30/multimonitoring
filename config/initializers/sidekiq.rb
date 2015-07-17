require 'sidekiq'

redis_url = ENV['REDIS_URI'] || ENV[ENV['REDIS_PROVIDER'].to_s] || 'redis://localhost:6379/'

Sidekiq.configure_server do |config|
  config.redis = { :url =>  redis_url }
end

$redis = Redis.new(url: redis_url)
