require 'party_foul/processors/sidekiq'

PartyFoul.configure do |config|
  config.owner = 'staticwebsitemanager'
  config.repo = 'app'
  config.oauth_token = ENV['GITHUB_ISSUES_OAUTH_TOKEN']
  config.api_endpoint = 'https://api.github.com'
  config.web_url = 'https://github.com'
  config.blacklisted_exceptions = ['ActiveRecord::RecordNotFound', 'ActionController::RoutingError']
  config.processor = PartyFoul::Processors::Sidekiq
end
