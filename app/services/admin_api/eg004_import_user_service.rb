class AdminApi::Eg004ImportUserService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:Admin4Step2
    configuration = DocuSign_Admin::Configuration.new
    configuration.host = Rails.configuration.admin_host

    api_client = DocuSign_Admin::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    #ds-snippet-end:Admin4Step2

    #ds-snippet-start:Admin4Step3
    csv_file_data = File.open(args[:csv_file_path]).read
    csv_file_data = csv_file_data.gsub('{account_id}', args[:account_id])

    @bulk_imports_api = DocuSign_Admin::BulkImportsApi.new(api_client)
    results, _status, headers = @bulk_imports_api.create_bulk_import_add_users_request_with_http_info(args[:organization_id], csv_file_data)

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:Admin4Step3

    results
  end
end
