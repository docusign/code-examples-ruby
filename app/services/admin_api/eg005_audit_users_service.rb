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
    modified_users, _status, headers = users_api.get_users_with_http_info(args[:organization_id], options)

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:Admin5Step3

    #ds-snippet-start:Admin5Step5
    results = []
    modified_users.as_json['users'].each do |user|
      #ds-snippet-end:Admin5Step5
      #ds-snippet-start:Admin5Step4
      userProfilesOptions = DocuSign_Admin::GetUserProfilesOptions.new
      userProfilesOptions.email = user['email']
      #ds-snippet-end:Admin5Step4
      #ds-snippet-start:Admin5Step5
      result, _status, headers = users_api.get_user_profiles_with_http_info(args[:organization_id], userProfilesOptions)

      remaining = headers['X-RateLimit-Remaining']
      reset = headers['X-RateLimit-Reset']

      if remaining && reset
        reset_date = Time.at(reset.to_i).utc
        puts "API calls remaining: #{remaining}"
        puts "Next Reset: #{reset_date}"
      end

      results.push(result)
    end
    #ds-snippet-end:Admin5Step5

    results
  end
end
