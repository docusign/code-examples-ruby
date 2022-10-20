class AdminApi::Eg003BulkExportUserDataService
  attr_reader :bulk_exports_api, :args

  def initialize(args)
    @args = args
  end

  def worker
    # Step 2 start
    configuration = DocuSign_Admin::Configuration.new
    configuration.host = Rails.configuration.admin_host

    api_client = DocuSign_Admin::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    # Step 2 end

    # Step 3 start
    @bulk_exports_api = DocuSign_Admin::BulkExportsApi.new(api_client)
    response = bulk_exports_api.create_user_list_export(args[:organization_id], args[:request_body])
    # Step 3 end

    # Step 4 start
    retry_count = 5
    while retry_count >= 0
      if response.results
        get_exported_user_data(args, response.id)
        break
      else
        retry_count -= 1
        sleep(5)
        response = bulk_exports_api.get_user_list_export(args[:organization_id], response.id)
      end
    end
    # Step 4 end

    response
  end

  private

  # Step 5 start
  def get_exported_user_data(args, export_id)
    bulk_export_response = bulk_exports_api.get_user_list_export(args[:organization_id], export_id)
    data_url = bulk_export_response.results[0].url

    uri = URI(data_url)

    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{args[:access_token]}"

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    http.request(req) do |response|
      File.open(args[:file_path], 'w') do |file|
        response.read_body do |chunk|
          file.write(chunk)
        end
      end
    end
  end
  # Step 5 end
end
