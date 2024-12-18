# frozen_string_literal: true

class MonitorApi::Eg001GetMonitoringDatasetService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:Monitor1Step2
    configuration = DocuSign_Monitor::Configuration.new
    configuration.host = Rails.configuration.monitor_host
    configuration.debugging = true
    api_client = DocuSign_Monitor::ApiClient.new configuration
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    #ds-snippet-end:Monitor1Step2

    #ds-snippet-start:Monitor1Step3
    monitor_api = DocuSign_Monitor::DataSetApi.new(api_client)
    begin
      cursor_value = '2024-01-01T00:00:00Z'
      limit = 2000
      function_results = []
      options = DocuSign_Monitor::GetStreamOptions.new
      options.limit = limit

      loop do
        options.cursor = cursor_value unless cursor_value.empty?

        cursored_results = monitor_api.get_stream(args[:data_set_name], args[:version], options)
        end_cursor = cursored_results.end_cursor

        break if cursor_value == end_cursor

        cursor_value = end_cursor
        function_results.push(cursored_results.data)
      end
      @response = function_results
    #ds-snippet-end:Monitor1Step3
    rescue Exception => e
      # error, probalby no Monitor enabled
      @response = e
    else
      Rails.logger.info 'Responses for loops are displayed here. Only the final loop is displayed on the response page'
      Rails.logger.info @response.inspect
    ensure
      return @response
    end
  end
end
