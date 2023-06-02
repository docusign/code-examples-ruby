# frozen_string_literal: true

class AdminApi::Eg011DeleteUserDataFromAccountService
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
    accounts_api = DocuSign_Admin::AccountsApi.new(api_client)
    membership_redaction_request = DocuSign_Admin::IndividualMembershipDataRedactionRequest.new(
      user_id: args[:user_id]
    )
    accounts_api.redact_individual_membership_data(args[:account_id], membership_redaction_request)
    # Step 3 end
  end
end
