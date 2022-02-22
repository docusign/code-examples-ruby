# frozen_string_literal: true

class AdminApi::Eg002CreateActiveClmEsignUserService
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

    # Step 6 start
    users_api = DocuSign_Admin::UsersApi.new(api_client)
    response = users_api.add_or_update_user(args[:organization_id], args[:account_id], body(args))
    # Step 6 end
  end

  private

  # Step 5 start
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
  # Step 5 end
end