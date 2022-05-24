class MonitorApi::Eg001GetMonitoringDatasetController < EgController
  before_action :check_auth

  def create
    args = {
      access_token: session[:ds_access_token],
      data_set_name: 'monitor',
      version: '2.0'
    }

    results = MonitorApi::Eg001GetMonitoringDatasetService.new(args).worker

    @title = "Get monitoring data"
    @h1 = "Get monitoring data"
    @message = "Results from DataSet:getStream method:"
    @json = results.to_json.to_json

    render 'ds_common/example_done'
  end
end
