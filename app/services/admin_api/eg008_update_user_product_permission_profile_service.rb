# frozen_string_literal: true

class AdminApi::Eg008UpdateUserProductPermissionProfileService
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
    product_permission_profile = DocuSign_Admin::ProductPermissionProfileRequest.new({ 'permission_profile_id' => args[:permission_profile_id], 'product_id' => args[:product_id] })
    user_product_permission_profile_request = DocuSign_Admin::UserProductPermissionProfilesRequest.new({ 'email' => args[:email], 'product_permission_profiles' => [product_permission_profile] })
    # Step 3 end

    # Step 4 start
    product_permission_profiles_api = DocuSign_Admin::ProductPermissionProfilesApi.new(api_client)
    product_permission_profiles_api.add_user_product_permission_profiles_by_email(args[:organization_id], args[:account_id], user_product_permission_profile_request)
    # Step 4 end
  end
end
