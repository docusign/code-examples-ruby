# frozen_string_literal: true

module ApiCreator
  def create_initial_api_client(host: nil, debugging: false)
    if Rails.configuration.examples_API['Rooms'] == true
      api_client = new_client(DocuSign_Rooms, debugging)
    elsif Rails.configuration.examples_API['Click'] == true
      api_client = new_client(DocuSign_Click, debugging)
    elsif Rails.configuration.examples_API['Monitor'] == true
      api_client = new_client(DocuSign_Monitor, debugging)
    else
      api_client = new_client(DocuSign_eSign, debugging)
    end
    api_client.set_oauth_base_path(host)
    api_client
  end

  def new_client(client_module, debugging)
    configuration = client_module::Configuration.new
    configuration.debugging = debugging
    client_module::ApiClient.new(configuration)
  end

  def create_account_api(args)
    # Obtain your OAuth token
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:base_path]
    api_client = DocuSign_eSign::ApiClient.new configuration

    # Construct your API headers
    api_client.default_headers['Authorization'] = "Bearer #{args[:access_token]}"

    # Construct your request body
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
    # Obtain your OAuth token
    # Step 2 start
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:base_path]
    api_client = DocuSign_eSign::ApiClient.new configuration

    api_client.default_headers['Authorization'] = "Bearer #{args[:access_token]}"
    # Step 2 end
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
