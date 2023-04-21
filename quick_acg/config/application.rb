require_relative 'boot'
require 'rails/all'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
module CodeExamplesRuby
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    # Configuration for DocuSign example.
    # For a production application, you will store the credentials
    # in config/environments/development.rb, production.rb, test.rb, etc
    config.app_url = 'http://localhost:3000' # The public url of the application.
    # Init DocuSign configuration, loaded from config/appsettings.yml file
    DOCUSIGN_CONFIG = YAML.load_file(File.join(Rails.root, '../config/appsettings.yml'), aliases: true)[Rails.env]
    DOCUSIGN_CONFIG.map do |k, v|
      config.send("#{k}=", v)
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
