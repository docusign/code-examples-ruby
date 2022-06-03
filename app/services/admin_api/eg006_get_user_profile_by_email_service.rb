# frozen_string_literal: true

class AdminApi::Eg006GetUserProfileByEmailService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    # Step 2 start
    configuration = DocuSign_Admin::Configuration.new
    configuration.host = Rails.configuration.admin_host

    api_client = DocuSign_Admin::ApiClient.new(configuration)
    api_client.set_default_header("Authorization", "Bearer #{args[:access_token]}")
    # Step 2 end

    # Step 3 start
    users_api = DocuSign_Admin::UsersApi.new(api_client)

    options = DocuSign_Admin::GetUserDSProfilesByEmailOptions.new
    options.email = args[:email]
    response = users_api.get_user_ds_profiles_by_email(args[:organization_id], options)
    # Step 3 end
  end
end
