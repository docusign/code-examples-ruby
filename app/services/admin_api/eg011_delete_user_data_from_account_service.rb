# frozen_string_literal: true

class AdminApi::Eg011DeleteUserDataFromAccountService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:Admin11Step2
    configuration = DocuSign_Admin::Configuration.new
    configuration.host = Rails.configuration.admin_host

    api_client = DocuSign_Admin::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    #ds-snippet-end:Admin11Step2

    #ds-snippet-start:Admin11Step3
    accounts_api = DocuSign_Admin::AccountsApi.new(api_client)
    membership_redaction_request = DocuSign_Admin::IndividualMembershipDataRedactionRequest.new(
      user_id: args[:user_id]
    )
    #ds-snippet-end:Admin11Step3

    #ds-snippet-start:Admin11Step4
    results, _status, headers = accounts_api.redact_individual_membership_data_with_http_info(args[:account_id], membership_redaction_request)

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:Admin11Step4

    results
  end
end
