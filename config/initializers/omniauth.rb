# frozen_string_literal: true

require 'docusign'

# Defaults to STDOUT: https://github.com/omniauth/omniauth#logging
# Logs entries like:
# (docusign) Setup endpoint detected, running now.
# (docusign) Request phase initiated.
# (docusign) Callback phase initiated.
OmniAuth.config.logger = Rails.logger

# https://github.com/omniauth/omniauth/wiki/FAQ#omniauthfailureendpoint-does-not-redirect-in-development-mode
# otherwise a callback exception like the following will not get caught:
# OmniAuth::Strategies::OAuth2::CallbackError (access_denied)
# GET "/auth/docusign/callback?error=access_denied&error_message=The%20user%20did%20not%20consent%20to%20connecting%20the%20application.&state=
# OmniAuth.config.failure_raise_out_environments = [] # defaults to: ['development']

config = Rails.application.config
config.middleware.use OmniAuth::Builder do
  # OAuth2 login request configuration
  # OAuth2 login response callback message configuration is in OmniAuth::Strategies::Docusign in lib/docusign.rb
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
    if Rails.configuration.examples_API == 'Rooms'
      strategy.options[:authorize_params].scope = "signature dtr.rooms.read dtr.rooms.write dtr.documents.read dtr.documents.write dtr.profile.read dtr.profile.write dtr.company.read dtr.company.write room_forms"
    end
  }
end
