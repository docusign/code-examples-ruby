# frozen_string_literal: true

class Clickwrap::Eg002ActivateClickwrapService
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

    # Step 3. Construct the request body
    # Create a clickwrap request model
    clickwrap_request = DocuSign_Click::ClickwrapRequest.new(status: 'active')

    # Step 4. Call the Click API
    accounts_api = DocuSign_Click::AccountsApi.new(api_client)
    accounts_api.update_clickwrap_version(
      args[:account_id],
      args[:clickwrap_id],
      1,
      clickwrap_request
    )
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
      clickwraps.concat accounts_api.get_clickwraps(
        args[:ds_account_id],
        options
      ).clickwraps
    end

    clickwraps
  end
end
