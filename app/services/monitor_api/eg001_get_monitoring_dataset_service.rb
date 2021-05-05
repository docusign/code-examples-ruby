# frozen_string_literal: true

class MonitorApi::Eg001GetMonitoringDatasetService
  attr_reader :args

  def initialize(session, _request)
    @args = {
      # account_id: session[:ds_account_id],
      access_token: session[:ds_access_token]
    }
    @cursor = ''
    @results_memo = []
    @last_result = ''
  end

  def call
    # step 2 start
    configuration = DocuSign_Monitor::Configuration.new
    configuration.host = Rails.configuration.monitor_host
    configuration.debugging = true
    api_client = DocuSign_Monitor::ApiClient.new configuration
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    # step 2 end

    # step 3 start
    while true do
      monitor_api = DocuSign_Monitor::DataSetApi.new(api_client)
      options = DocuSign_Monitor::GetStreamForDatasetOptions.default
      options.cursor = @cursor
      response = monitor_api.get_stream_for_dataset('monitor', '2.0', options).first

      # If the endCursor from the response is the same as the one that you already have,
      # it means that you have reached the end of the records
      break if response[:endCursor] == @cursor

      @results_memo.push(response[:data])
      @last_result = response[:data]
      @cursor = response[:endCursor]
    end
    # step 3 end 
    
    Rails.logger.info "Responses for loops are displayed here. Only the final loop is displayed on the response page"
    Rails.logger.info @results_memo.inspect

    return @last_result
  end
end