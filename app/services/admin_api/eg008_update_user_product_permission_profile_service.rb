# frozen_string_literal: true

class AdminApi::Eg008UpdateUserProductPermissionProfileService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:Admin8Step2
    configuration = DocuSign_Admin::Configuration.new
    configuration.host = Rails.configuration.admin_host

    api_client = DocuSign_Admin::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    #ds-snippet-end:Admin8Step2

    #ds-snippet-start:Admin8Step3
    product_permission_profile = DocuSign_Admin::ProductPermissionProfileRequest.new({ 'permission_profile_id' => args[:permission_profile_id], 'product_id' => args[:product_id] })
    user_product_permission_profile_request = DocuSign_Admin::UserProductPermissionProfilesRequest.new({ 'email' => args[:email], 'product_permission_profiles' => [product_permission_profile] })
    #ds-snippet-end:Admin8Step3

    #ds-snippet-start:Admin8Step4
    product_permission_profiles_api = DocuSign_Admin::ProductPermissionProfilesApi.new(api_client)
    product_permission_profiles_api.add_user_product_permission_profiles_by_email(args[:organization_id], args[:account_id], user_product_permission_profile_request)
    #ds-snippet-end:Admin8Step4
  end
end
