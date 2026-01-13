# frozen_string_literal: true

class AdminApi::Eg002CreateActiveClmEsignUserService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    configuration = DocuSign_Admin::Configuration.new
    configuration.host = Rails.configuration.admin_host

    api_client = DocuSign_Admin::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")

    #ds-snippet-start:Admin2Step6
    users_api = DocuSign_Admin::UsersApi.new(api_client)
    results, _status, headers = users_api.add_or_update_user_with_http_info(args[:organization_id], args[:account_id], body(args))

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:Admin2Step6

    results
  end

  private

  #ds-snippet-start:Admin2Step5
  def body(args)
    {
      user_name: args[:user_name],
      first_name: args[:first_name],
      last_name: args[:last_name],
      email: args[:email],
      auto_activate_memberships: true,
      product_permission_profiles: [
        {
          permission_profile_id: args[:esign_permission_profile_id],
          product_id: args[:esign_product_id]
        },
        {
          permission_profile_id: args[:clm_permission_profile_id],
          product_id: args[:clm_product_id]
        }
      ],
      ds_groups: [
        {
          ds_group_id: args[:ds_group_id]
        }
      ]
    }
  end
  #ds-snippet-end:Admin2Step5
end
