# frozen_string_literal: true

class AdminApi::Eg001CreateUserService
  attr_reader :args, :user_data

  def initialize(session, request)
    @args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      organization_id: session['organization_id']
    }

    # Step 5 start
    @user_data = {
      user_name: request.params['user_name'].gsub(/([^\w \-\@\.\,])+/, ''),
      first_name: request.params['first_name'].gsub(/([^\w \-\@\.\,])+/, ''),
      last_name: request.params['last_name'].gsub(/([^\w \-\@\.\,])+/, ''),
      email: request.params['email'].gsub(/([^\w \-\@\.\,])+/, ''),
      auto_activate_memberships: true,
      accounts: [
        {
          id: args[:account_id],
          permission_profile: {
            id: request['permission_profile_id']
          },
          groups: [
            {
              id: request['group_id']
            }
          ]
        }
      ]
    }
    # Step 5 end
  end

  def call
    worker
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
    response = users_api.create_user(args[:organization_id], user_data)
    # Step 6 end
  end

  def self.get_permission_profiles_and_groups
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:ds_base_path]

    api_client = DocuSign_eSign::ApiClient.new(configuration)
    api_client.set_default_header("Authorization", "Bearer #{args[:access_token]}")
    
    # Step 3 start
    accounts_api = DocuSign_eSign::AccountsApi.new(api_client)
    profiles = accounts_api.list_permissions(args[:account_id])
    # Step 3 end
    
    # Step 4 start    
    groups_api = DocuSign_eSign::GroupsApi.new(api_client)
    groups = groups_api.list_groups(args[:account_id])
    # Step 4 end
    return profiles, groups
  end
end
