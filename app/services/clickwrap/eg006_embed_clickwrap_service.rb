# frozen_string_literal: true

class Clickwrap::Eg006EmbedClickwrapService
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
    api_client.config.debugging = true;

    # document_data = DocuSign_Click::DocumentData.new({
    #   full_name: args[:full_name],
    #   email: args[:email],
    #   company: args[:company],
    #   title: args[:title],
    #   date: args[:date]
    # })

    document_data = {
      "fullName" => args[:full_name],
      "email" => args[:email],
      "company" => args[:company],
      "title" => args[:title],
      "date" => args[:date]
    }


    userAgreementRequest = DocuSign_Click::UserAgreementRequest.new({
      clientUserId: args[:email],
      documentData: document_data
    })

    accounts_api = DocuSign_Click::AccountsApi.new(api_client)

    response = accounts_api.create_has_agreed(args[:account_id], args[:clickwrap_id], userAgreementRequest)

    response.as_json
  end

  def get_active_clickwraps
    configuration = DocuSign_Click::Configuration.new
    configuration.host = args[:ds_base_path]

    api_client = DocuSign_Click::ApiClient.new configuration
    api_client.set_default_header('Authorization', "Bearer #{args[:ds_access_token]}")

    accounts_api = DocuSign_Click::AccountsApi.new(api_client)

    options = DocuSign_Click::GetClickwrapsOptions.new
    options.status = 'active'

    results = accounts_api.get_clickwraps(
      args[:ds_account_id],
      options
    )
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

    results = accounts_api.get_clickwraps(
      args[:ds_account_id],
      options
    )
    results.as_json['clickwraps']
  end
end
