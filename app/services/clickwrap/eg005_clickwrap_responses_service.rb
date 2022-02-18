# frozen_string_literal: true

class Clickwrap::Eg005ClickwrapResponsesService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    # Step 2. Construct your API headers
    configuration = DocuSign_Click::Configuration.new
    configuration.host = args[:base_path]

    api_client = DocuSign_Click::ApiClient.new configuration
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")

    # Step 3. Call the Click API
    # Set Clickwrap Agreements options
    agreements = DocuSign_Click::GetClickwrapAgreementsOptions.new
    agreements.client_user_id = args[:client_user_id]
    agreements.status = 'agreed'

    # Get clickwrap responses using SDK
    accounts_api = DocuSign_Click::AccountsApi.new(api_client)
    accounts_api.get_clickwrap_agreements(
      args[:account_id],
      args[:clickwrap_id],
      agreements
    )
  end
end
