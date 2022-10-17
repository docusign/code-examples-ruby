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

    if results != "Monitor not enabled"
      @message = "Results from DataSet:getStream method:"
      @json = results.to_json.to_json
    else
      @message = "You do not have Monitor enabled for your account, follow <a target='_blank' href='https://developers.docusign.com/docs/monitor-api/how-to/enable-monitor/'>How to enable Monitor for your account</a> to get it enabled."
    end

    render 'ds_common/example_done'
  end
end
