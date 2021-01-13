# frozen_string_literal: true

class Clickwrap::Eg005ClickwrapResponsesService
  attr_reader :args

  def initialize(session, request)
    @args = {
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token],
      clickwrap_id: session[:clickwrap_id],
      client_user_id: request[:client_user_id]
    }
  end

  def call
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
