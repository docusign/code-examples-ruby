# frozen_string_literal: true

class AdminApi::Eg009DeleteUserProductPermissionProfileService
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
    user_product_profile_delete_request = DocuSign_Admin::UserProductProfileDeleteRequest.new({ 'user_email' => args[:email], 'product_ids' => [args[:product_id]] })
    # Step 3 end

    # Step 4 start
    product_permission_profiles_api = DocuSign_Admin::ProductPermissionProfilesApi.new(api_client)
    product_permission_profiles_api.remove_user_product_permission(args[:organization_id], args[:account_id], user_product_profile_delete_request)
    # Step 4 end
  end

  def get_permission_profiles_by_email
    configuration = DocuSign_Admin::Configuration.new
    configuration.host = Rails.configuration.admin_host

    api_client = DocuSign_Admin::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")

    product_permission_profiles_api = DocuSign_Admin::ProductPermissionProfilesApi.new(api_client)

    options = DocuSign_Admin::GetUserProductPermissionProfilesByEmailOptions.new
    options.email = args[:email]

    product_permission_profiles = product_permission_profiles_api.get_user_product_permission_profiles_by_email(args[:organization_id], args[:account_id], options)
    product_permission_profiles.as_json['product_permission_profiles']
  end
end
