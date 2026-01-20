# frozen_string_literal: true

class AdminApi::Eg001CreateUserService
  attr_reader :args, :user_data

  def initialize(args, user_data)
    @args = args
    @user_data = user_data
  end

  def worker
    #ds-snippet-start:Admin1Step2
    configuration = DocuSign_Admin::Configuration.new
    configuration.host = Rails.configuration.admin_host

    api_client = DocuSign_Admin::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    #ds-snippet-end:Admin1Step2

    #ds-snippet-start:Admin1Step6
    users_api = DocuSign_Admin::UsersApi.new(api_client)
    results, _status, headers = users_api.create_user_with_http_info(args[:organization_id], user_data)

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:Admin1Step6

    results
  end
end
