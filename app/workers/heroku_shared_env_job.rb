
require './config/initializers/sidekiq'
require './lib/heroku_env_review'
require 'rest_client'


class HerokuSharedEnvJob

  include Sidekiq::Worker

  def perform(app)
    reviewer = HerokuEnvReview.new
    reviewer.review_app_shared_env_vars(app)
  end
end
