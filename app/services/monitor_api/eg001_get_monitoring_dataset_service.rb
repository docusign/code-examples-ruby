# frozen_string_literal: true

class MonitorApi::Eg001GetMonitoringDatasetService
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
      @response = monitor_api.get_stream(args[:data_set_name], args[:version]).data
      # step 3 end    
    rescue
      # error, probalby no Monitor enabled
      @response = "Monitor not enabled"
    else    
      Rails.logger.info "Responses for loops are displayed here. Only the final loop is displayed on the response page"
      Rails.logger.info @response.inspect
    ensure 
      return @response
    end
    
  end
end
