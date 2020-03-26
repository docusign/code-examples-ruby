# frozen_string_literal: true

require 'docusign'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :docusign, Rails.application.config.client_id, Rails.application.config.client_secret,
           setup: lambda { |env|
             strategy = env['omniauth.strategy']
             strategy.options[:client_options].site = Rails.application.config.app_url
             strategy.options[:prompt] = 'login'
             strategy.options[:oauth_base_uri] = Rails.application.config.authorization_server
             strategy.options[:target_account_id] = Rails.application.config.target_account_id
             strategy.options[:allow_silent_authentication] = Rails.application.config.allow_silent_authentication
           }
end
