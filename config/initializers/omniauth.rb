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
  }
end
