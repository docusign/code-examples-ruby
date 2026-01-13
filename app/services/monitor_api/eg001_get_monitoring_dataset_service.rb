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
      cursor_date = Date.today.prev_day
      cursor_value = cursor_date.strftime('%Y-%m-%dT00:00:00Z')
      limit = 2000
      function_results = []
      options = DocuSign_Monitor::GetStreamOptions.new
      options.limit = limit

      loop do
        options.cursor = cursor_value unless cursor_value.empty?

        cursored_results, _status, headers = monitor_api.get_stream_with_http_info(args[:data_set_name], args[:version], options)

        remaining = headers['X-RateLimit-Remaining']
        reset = headers['X-RateLimit-Reset']

        if remaining && reset
          reset_date = Time.at(reset.to_i).utc
          puts "API calls remaining: #{remaining}"
          puts "Next Reset: #{reset_date}"
        end

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
