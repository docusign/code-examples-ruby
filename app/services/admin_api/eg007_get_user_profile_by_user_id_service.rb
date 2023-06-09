# frozen_string_literal: true

class AdminApi::Eg007GetUserProfileByUserIdService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:Admin7Step2
    configuration = DocuSign_Admin::Configuration.new
    configuration.host = Rails.configuration.admin_host

    api_client = DocuSign_Admin::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    #ds-snippet-end:Admin7Step2

    #ds-snippet-start:Admin7Step3
    users_api = DocuSign_Admin::UsersApi.new(api_client)
    users_api.get_user_ds_profile(args[:organization_id], args[:user_id])
    #ds-snippet-end:Admin7Step3
  end
end
