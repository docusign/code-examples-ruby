# frozen_string_literal: true

class Clickwrap::Eg006EmbedClickwrapService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    # Step 2. Construct your API headers
    #ds-snippet-start:Click6Step2
    configuration = DocuSign_Click::Configuration.new
    configuration.host = args[:base_path]

    api_client = DocuSign_Click::ApiClient.new configuration
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    api_client.config.debugging = true
    #ds-snippet-end:Click6Step2

    #ds-snippet-start:Click6Step3
    document_data = {
      'fullName' => args[:full_name],
      'email' => args[:email],
      'company' => args[:company],
      'title' => args[:title],
      'date' => args[:date]
    }

    userAgreementRequest = DocuSign_Click::UserAgreementRequest.new({
                                                                      clientUserId: args[:email],
                                                                      documentData: document_data
                                                                    })

    #ds-snippet-end:Click6Step3
    #ds-snippet-start:Click6Step4
    accounts_api = DocuSign_Click::AccountsApi.new(api_client)

    response, _status, headers = accounts_api.create_has_agreed_with_http_info(args[:account_id], args[:clickwrap_id], userAgreementRequest)

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end

    response.as_json
    #ds-snippet-end:Click6Step4
  end

  def get_active_clickwraps
    configuration = DocuSign_Click::Configuration.new
    configuration.host = args[:ds_base_path]

    api_client = DocuSign_Click::ApiClient.new configuration
    api_client.set_default_header('Authorization', "Bearer #{args[:ds_access_token]}")

    accounts_api = DocuSign_Click::AccountsApi.new(api_client)

    options = DocuSign_Click::GetClickwrapsOptions.new
    options.status = 'active'

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

    puts results.as_json['clickwraps']
    results.as_json['clickwraps']
  end

  def get_inactive_clickwraps
    configuration = DocuSign_Click::Configuration.new
    configuration.host = args[:ds_base_path]

    api_client = DocuSign_Click::ApiClient.new configuration
    api_client.set_default_header('Authorization', "Bearer #{args[:ds_access_token]}")

    accounts_api = DocuSign_Click::AccountsApi.new(api_client)

    options = DocuSign_Click::GetClickwrapsOptions.new
    options.status = 'inactive'

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

    results.as_json['clickwraps']
  end
end
