# frozen_string_literal: true

class Clickwrap::Eg002ActivateClickwrapService
  attr_reader :args

  def initialize(session)
    @args = {
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token],
      clickwrap_id: session[:clickwrap_id]
    }
  end

  def call
    # Step 2. Construct your API headers
    configuration = DocuSign_Click::Configuration.new
    configuration.host = args[:base_path]

    api_client = DocuSign_Click::ApiClient.new configuration
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")

    # Step 3. Construct the request body
    # Create a clickwrap request model
    clickwrap_request = DocuSign_Click::ClickwrapRequest.new(status: 'active')

    # Step 4. Call the Click API
    accounts_api = DocuSign_Click::AccountsApi.new(api_client)
    response = accounts_api.update_clickwrap_version(
      args[:account_id],
      args[:clickwrap_id],
      1,
      clickwrap_request
    )
  end
end
