# frozen_string_literal: true

class Clickwrap::Eg004ListClickwrapsService
  attr_reader :args

  def initialize(session, _request)
    @args = {
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token]
    }
  end

  def call
    # Step 2. Construct your API headers
    configuration = DocuSign_Click::Configuration.new
    configuration.host = args[:base_path]

    api_client = DocuSign_Click::ApiClient.new configuration
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")

    # Step 3. Call the Click API
    accounts_api = DocuSign_Click::AccountsApi.new(api_client)
    accounts_api.get_clickwraps(
      args[:account_id]
    )
  end
end
