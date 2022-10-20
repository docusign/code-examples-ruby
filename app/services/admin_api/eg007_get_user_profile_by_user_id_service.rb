# frozen_string_literal: true

class AdminApi::Eg007GetUserProfileByUserIdService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    # Step 2 start
    configuration = DocuSign_Admin::Configuration.new
    configuration.host = Rails.configuration.admin_host

    api_client = DocuSign_Admin::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    # Step 2 end

    # Step 3 start
    users_api = DocuSign_Admin::UsersApi.new(api_client)
    users_api.get_user_ds_profile(args[:organization_id], args[:user_id])
    # Step 3 end
  end
end
