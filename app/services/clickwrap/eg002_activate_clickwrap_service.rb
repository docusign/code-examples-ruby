# frozen_string_literal: true

class Clickwrap::Eg002ActivateClickwrapService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    # Step 2. Construct your API headers
    #ds-snippet-start:Click2Step2
    configuration = DocuSign_Click::Configuration.new
    configuration.host = args[:base_path]

    api_client = DocuSign_Click::ApiClient.new configuration
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    #ds-snippet-end:Click2Step2

    # Step 3. Construct the request body
    # Create a clickwrap request model
    #ds-snippet-start:Click2Step3
    clickwrap_request = DocuSign_Click::ClickwrapRequest.new(status: 'active')
    #ds-snippet-end:Click2Step3

    # Step 4. Call the Click API
    #ds-snippet-start:Click2Step4
    accounts_api = DocuSign_Click::AccountsApi.new(api_client)
    results, _status, headers = accounts_api.update_clickwrap_version_with_http_info(
      args[:account_id],
      args[:clickwrap_id],
      1,
      clickwrap_request
    )

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:Click2Step4

    results
  end

  def get_inactive_clickwraps(statuses)
    configuration = DocuSign_Click::Configuration.new
    configuration.host = args[:ds_base_path]

    api_client = DocuSign_Click::ApiClient.new configuration
    api_client.set_default_header('Authorization', "Bearer #{args[:ds_access_token]}")

    accounts_api = DocuSign_Click::AccountsApi.new(api_client)

    clickwraps = []
    statuses.each do |status|
      options = DocuSign_Click::GetClickwrapsOptions.new
      options.status = status
      results, _status, headers = accounts_api.get_clickwraps_with_http_info(
        args[:ds_account_id],
        options
      )

      remaining = headers['X-RateLimit-Remaining']
      reset = headers['X-RateLimit-Reset']

      if remaining && reset
        reset_date = Time.at(reset.to_i).utc
        puts "API calls remaining: #{remaining}"
        puts "Next Reset: #{reset_date}"
      end

      clickwraps.concat results.clickwraps
    end

    clickwraps
  end
end
