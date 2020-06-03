require_relative 'boot'
require 'rails/all'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
module Eg03RubyAuthCodeGrant
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    # Configuration for DocuSign example.
    # For a production application, you will store the credentials
    # in config/environments/development.rb, production.rb, test.rb, etc
    config.app_url = 'http://localhost:3000' # The public url of the application.
    # Note that the setting which controls the host/port for your app
    # is determined by your app's web server. For the default puma
    # server, see config/puma.rb
    #
    # NOTE => You must add a Redirect URI of {app_url}/auth/docusign/callback
    #         to your Integration Key.
    #
    # NOTE: The terms "client_id" and "Integration key" are synonyms. They refer to the same thing.
    config.client_id = '{INTEGRATION_KEY}'
    config.signer_email =  '{SIGNER_EMAIL}'
    config.signer_name = '{SIGNER_NAME}'
    config.cc_email = '{CC_EMAIL}'
    config.cc_name = '{CC_NAME}'
    config.aud ="account-d.docusign.com"

    ## NOTE: fill in the client secret for Authorization Code Grant flow OAuth
    config.client_secret = '{INTEGRATION_SECRET}'

    # NOTE: impersonated_user_guid and user ID are synonyms. They refer to the same thing.
    # the impersonated_user_guid will need to be filled out if using JSON Web Token (JWT) grant flow OAuth
    # Also fill in your RSA private key located: app\services\jwt_auth\docusign_private_key.txt 
    config.impersonated_user_guid = '{IMPERSONATED_USER_GUID}'


    config.authorization_server = 'https://account-d.docusign.com'
    config.allow_silent_authentication = true # a user can be silently authenticated if they have an
                                              # active login session on another tab of the same browser
    # Set if you want a specific DocuSign AccountId, If false, the user's default account will be used.
    config.target_account_id = false
    # Payment gateway information is optional. It is only needed for example 14.
    # See the PAYMENTS_INSTALLATION.md file for instructions
    config.gateway_account_id = '{DS_PAYMENT_GATEWAY_ID}'
    # The remainder of this file is already configured.
    config.demo_doc_path = 'demo_documents'
    config.doc_docx = 'World_Wide_Corp_Battle_Plan_Trafalgar.docx'
    config.doc_pdf = 'World_Wide_Corp_lorem.pdf'
    config.gateway_name = "stripe"
    config.gateway_display_name = "Stripe"
    config.github_example_url = 'https://github.com/docusign/eg-03-ruby-auth-code-grant/tree/master/app/controllers/'
    config.documentation = false
    config.api_only = false
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end