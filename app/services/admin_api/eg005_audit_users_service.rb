# frozen_string_literal: true

class AdminApi::Eg005AuditUsersService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:Admin5Step2
    configuration = DocuSign_Admin::Configuration.new
    configuration.host = Rails.configuration.admin_host

    api_client = DocuSign_Admin::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    #ds-snippet-end:Admin5Step2

    #ds-snippet-start:Admin5Step3
    options = DocuSign_Admin::GetUsersOptions.new
    options.account_id = args[:account_id]
    options.last_modified_since = (Date.today - 10).strftime('%Y/%m/%d')

    users_api = DocuSign_Admin::UsersApi.new(api_client)
    modified_users = users_api.get_users(args[:organization_id], options).as_json['users']
    #ds-snippet-end:Admin5Step3

    #ds-snippet-start:Admin5Step5
    results = []
    modified_users.each do |user|
      userProfilesOptions = DocuSign_Admin::GetUserProfilesOptions.new
      userProfilesOptions.email = user['email']
      result = users_api.get_user_profiles(args[:organization_id], userProfilesOptions)
      results.push(result)
    end
    #ds-snippet-end:Admin5Step5

    results
  end
end
