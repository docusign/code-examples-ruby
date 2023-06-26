# frozen_string_literal: true

class AdminApi::Eg006GetUserProfileByEmailService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:Admin6Step2
    configuration = DocuSign_Admin::Configuration.new
    configuration.host = Rails.configuration.admin_host

    api_client = DocuSign_Admin::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    #ds-snippet-end:Admin6Step2

    #ds-snippet-start:Admin6Step3
    users_api = DocuSign_Admin::UsersApi.new(api_client)

    options = DocuSign_Admin::GetUserDSProfilesByEmailOptions.new
    options.email = args[:email]
    users_api.get_user_ds_profiles_by_email(args[:organization_id], options)
    #ds-snippet-end:Admin6Step3
  end
end
