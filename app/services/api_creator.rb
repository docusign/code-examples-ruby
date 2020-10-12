# frozen_string_literal: true

module ApiCreator
  def create_initial_api_client(debugging: false)
    configuration = DocuSign_eSign::Configuration.new

    # https://github.com/docusign/docusign-ruby-client/blob/master/lib/docusign_esign/configuration.rb#L55-L60
    configuration.debugging = debugging

    api_client = DocuSign_eSign::ApiClient.new(configuration)
  end

  def create_account_api(args)
    # Step 1. Obtain your OAuth token
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:base_path]
    api_client = DocuSign_eSign::ApiClient.new configuration

    # Step 2. Construct your API headers
    api_client.default_headers['Authorization'] = "Bearer #{args[:access_token]}"

    # Step 3: Construct your request body
    accounts_api = DocuSign_eSign::AccountsApi.new api_client
  end
  
  def create_template_api(args)
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:base_path]
    api_client = DocuSign_eSign::ApiClient.new configuration
    api_client.default_headers['Authorization'] = "Bearer #{args[:access_token]}"
    templates_api = DocuSign_eSign::TemplatesApi.new api_client
  end

  def create_envelope_api(args)
    # Step 1. Obtain your OAuth token
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:base_path]
    api_client = DocuSign_eSign::ApiClient.new configuration

    # Step 2. Construct your API headers
    api_client.default_headers['Authorization'] = "Bearer #{args[:access_token]}"
    DocuSign_eSign::EnvelopesApi.new api_client
  end

  def create_group_api(args)
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:base_path]
    api_client = DocuSign_eSign::ApiClient.new configuration
    api_client.default_headers['Authorization'] = "Bearer #{args[:access_token]}"
    group_api = DocuSign_eSign::GroupsApi.new api_client
  end
end
