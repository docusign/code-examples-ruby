# frozen_string_literal: true

require 'docusign'

config = Rails.application.config
config.middleware.use OmniAuth::Builder do
  provider :docusign, config.integration_key, config.integration_secret, setup: lambda { |env|
    strategy = env['omniauth.strategy']
    strategy.options[:client_options].site = config.app_url
    strategy.options[:prompt] = 'login'
    strategy.options[:oauth_base_uri] = config.authorization_server
    strategy.options[:target_account_id] = config.target_account_id
    strategy.options[:allow_silent_authentication] = config.allow_silent_authentication
    strategy.options[:client_options].authorize_url = "#{strategy.options[:oauth_base_uri]}/oauth/auth"
    strategy.options[:client_options].user_info_url = "#{strategy.options[:oauth_base_uri]}/oauth/userinfo"
    strategy.options[:client_options].token_url = "#{strategy.options[:oauth_base_uri]}/oauth/token"
    unless strategy.options[:allow_silent_authentication]
      strategy.options[:authorize_params].prompt = strategy.options.prompt
    end
    if Rails.configuration.examples_API == 'roomsAPI'
      strategy.options[:authorize_params].scope = "signature dtr.rooms.read dtr.rooms.write dtr.documents.read dtr.documents.write dtr.profile.read dtr.profile.write dtr.company.read dtr.company.write room_forms"
    end
  }
end
