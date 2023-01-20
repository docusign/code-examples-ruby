# frozen_string_literal: true

class MonitorApi::Eg002PostWebQueryService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    # step 2 start
    configuration = DocuSign_Monitor::Configuration.new
    configuration.host = Rails.configuration.monitor_host
    configuration.debugging = true
    api_client = DocuSign_Monitor::ApiClient.new configuration
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    # step 2 end

    # step 3 start
    monitor_api = DocuSign_Monitor::DataSetApi.new(api_client)
    begin
      @response = monitor_api.post_web_query(args[:data_set_name], args[:version], get_query)
      # step 3 end
    rescue StandardError
      # error, probalby no Monitor enabled
      @response = 'Monitor not enabled'
    else
      Rails.logger.info 'Responses for loops are displayed here. Only the final loop is displayed on the response page'
      Rails.logger.info @response.inspect
    ensure
      return @response
    end
  end

  def get_query
    {
      "filters": [
        {
          "FilterName": 'Time',
          "BeginTime": args[:start_date],
          "EndTime": args[:end_date]
        },
        {
          "FilterName": 'Has',
          "ColumnName": 'AccountId',
          "Value": args[:account_id]
        }
      ],
      "aggregations": [
        {
          "aggregationName": 'Raw',
          "limit": '100',
          "orderby": [
            'Timestamp, desc'
          ]
        }
      ]
    }
  end
end
