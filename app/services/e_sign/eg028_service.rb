# frozen_string_literal: true

class ESign::Eg028Service
  include ApiCreator
  attr_reader :args, :session, :request

  def initialize(session, request)
    @args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token']
    }
    @session = session
    @request = request
  end

  def call
    # Step 1. Obtain your OAuth token
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:base_path]
    api_client = DocuSign_eSign::ApiClient.new configuration

    # Step 2. Construct your API headers
    api_client.default_headers['Authorization'] = "Bearer #{args[:access_token]}"

    # Step 3: Construct your request body
    accounts_api = DocuSign_eSign::AccountsApi.new api_client
    params = { brandName:  request.params[:brandName], defaultBrandLanguage: request.params[:defaultBrandLanguage] }
    
    # Step 4: Call the eSignature API
    results = accounts_api.create_brand(session['ds_account_id'], params)
  end
end