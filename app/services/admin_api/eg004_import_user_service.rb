require 'uri'
require 'net/http'

class AdminApi::Eg004ImportUserService
  attr_reader :args, :user_data

  def initialize(session, request, csv_file_path)
    @args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      organization_id: session['organization_id'],
      csv_file_path: csv_file_path
    }

  end

  def call
    worker
  end

  def worker
    # Step 2 start
    configuration = DocuSign_Admin::Configuration.new
    configuration.host = Rails.configuration.admin_host

    api_client = DocuSign_Admin::ApiClient.new(configuration)
    api_client.set_default_header("Authorization", "Bearer #{args[:access_token]}")
    # Step 2 end

    # Step 3 start
    csv_file_data = File.open(args[:csv_file_path]).read
    csv_file_data = csv_file_data.gsub('{account_id}', args[:account_id])

    @bulk_imports_api = DocuSign_Admin::BulkImportsApi.new(api_client)
    response = @bulk_imports_api.create_bulk_import_add_users_request(args[:organization_id], csv_file_data)
    # Step 3 end
    return response
  end
end