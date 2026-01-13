# frozen_string_literal: true

class AdminApi::Eg009DeleteUserProductPermissionProfileService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:Admin9Step2
    configuration = DocuSign_Admin::Configuration.new
    configuration.host = Rails.configuration.admin_host

    api_client = DocuSign_Admin::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    #ds-snippet-end:Admin9Step2

    #ds-snippet-start:Admin9Step4
    user_product_profile_delete_request = DocuSign_Admin::UserProductProfileDeleteRequest.new({ 'user_email' => args[:email], 'product_ids' => [args[:product_id]] })
    #ds-snippet-end:Admin9Step4

    #ds-snippet-start:Admin9Step5
    product_permission_profiles_api = DocuSign_Admin::ProductPermissionProfilesApi.new(api_client)
    results, _status, headers = product_permission_profiles_api.remove_user_product_permission_with_http_info(args[:organization_id], args[:account_id], user_product_profile_delete_request)

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:Admin9Step5

    results
  end

  def get_permission_profiles_by_email
    configuration = DocuSign_Admin::Configuration.new
    configuration.host = Rails.configuration.admin_host

    api_client = DocuSign_Admin::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")

    #ds-snippet-start:Admin9Step3
    product_permission_profiles_api = DocuSign_Admin::ProductPermissionProfilesApi.new(api_client)

    options = DocuSign_Admin::GetUserProductPermissionProfilesByEmailOptions.new
    options.email = args[:email]

    product_permission_profiles, _status, headers = product_permission_profiles_api.get_user_product_permission_profiles_by_email_with_http_info(args[:organization_id], args[:account_id], options)

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end

    product_permission_profiles.as_json['product_permission_profiles']
    #ds-snippet-end:Admin9Step3
  end
end
