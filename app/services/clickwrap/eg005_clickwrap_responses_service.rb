# frozen_string_literal: true

class Clickwrap::Eg005ClickwrapResponsesService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    # Step 2. Construct your API headers
    #ds-snippet-start:Click5Step2
    configuration = DocuSign_Click::Configuration.new
    configuration.host = args[:base_path]

    api_client = DocuSign_Click::ApiClient.new configuration
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    #ds-snippet-end:Click5Step2

    # Step 3. Call the Click API
    #ds-snippet-start:Click5Step3
    # Set Clickwrap Agreements options
    agreements = DocuSign_Click::GetClickwrapAgreementsOptions.new
    agreements.client_user_id = args[:client_user_id]
    agreements.status = 'agreed'

    # Get clickwrap responses using SDK
    accounts_api = DocuSign_Click::AccountsApi.new(api_client)
    results, _status, headers = accounts_api.get_clickwrap_agreements_with_http_info(
      args[:account_id],
      args[:clickwrap_id],
      agreements
    )

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:Click5Step3

    results
  end
end
