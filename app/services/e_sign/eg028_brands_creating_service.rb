# frozen_string_literal: true

class ESign::Eg028BrandsCreatingService
  attr_reader :args
  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    # Step 1. Obtain your OAuth token
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:base_path]
    api_client = DocuSign_eSign::ApiClient.new configuration

    # Step 2. Construct your API headers
    api_client.default_headers['Authorization'] = "Bearer #{args[:access_token]}"

    # Step 3: Construct your request body
    accounts_api = DocuSign_eSign::AccountsApi.new api_client
    params = { brandName:  args[:brandName], defaultBrandLanguage: args[:defaultBrandLanguage] }
    
    # Step 4: Call the eSignature API
    results = accounts_api.create_brand(args[:account_id], params)
  end
end