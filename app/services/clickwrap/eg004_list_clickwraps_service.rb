# frozen_string_literal: true

class Clickwrap::Eg004ListClickwrapsService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    # Step 2. Construct your API headers
    #ds-snippet-start:Click4Step2
    configuration = DocuSign_Click::Configuration.new
    configuration.host = args[:base_path]

    api_client = DocuSign_Click::ApiClient.new configuration
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    #ds-snippet-end:Click4Step2

    # Step 3. Call the Click API
    #ds-snippet-start:Click4Step3
    accounts_api = DocuSign_Click::AccountsApi.new(api_client)
    results, _status, headers = accounts_api.get_clickwraps_with_http_info(
      args[:account_id]
    )

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:Click4Step3

    results
  end
end
