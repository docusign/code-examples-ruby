# frozen_string_literal: true

module ApiCreator
  def create_initial_api_client(host: nil, client_module: DocuSign_eSign, debugging: false)
    configuration = client_module::Configuration.new
    configuration.debugging = debugging
    api_client = client_module::ApiClient.new(configuration)
    api_client.set_oauth_base_path(host)
    api_client
  end

  def create_account_api(args)
    # Obtain your OAuth token
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:base_path]
    api_client = DocuSign_eSign::ApiClient.new configuration

    # Construct your API headers
    api_client.default_headers['Authorization'] = "Bearer #{args[:access_token]}"

    # Construct your request body
    DocuSign_eSign::AccountsApi.new api_client
  end

  def create_template_api(args)
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:base_path]
    api_client = DocuSign_eSign::ApiClient.new configuration
    api_client.default_headers['Authorization'] = "Bearer #{args[:access_token]}"
    DocuSign_eSign::TemplatesApi.new api_client
  end

  def create_envelope_api(args)
    # Obtain your OAuth token
    # Step 2 start
    #ds-snippet-start eSign29Step2
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:base_path]
    api_client = DocuSign_eSign::ApiClient.new configuration

    api_client.default_headers['Authorization'] = "Bearer #{args[:access_token]}"
    #ds-snippet-end eSign29Step2
    # Step 2 end
    DocuSign_eSign::EnvelopesApi.new api_client
  end

  def create_group_api(args)
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:base_path]
    api_client = DocuSign_eSign::ApiClient.new configuration
    api_client.default_headers['Authorization'] = "Bearer #{args[:access_token]}"
    DocuSign_eSign::GroupsApi.new api_client
  end
end
