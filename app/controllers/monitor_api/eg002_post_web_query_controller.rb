class MonitorApi::Eg002PostWebQueryController < EgController
  before_action :check_auth

  def create
    args = {
      access_token: session[:ds_access_token],
      data_set_name: 'monitor',
      account_id: session['ds_account_id'],
      version: '2.0',
      start_date: params[:start_date],
      end_date: params[:end_date]
    }

    results = MonitorApi::Eg002PostWebQueryService.new(args).worker

    @title = "Query monitoring data with filters"
    @h1 = "Query monitoring data with filters"
    @message = "Results from DataSet:postWebQuery method:"
    @json = results.to_json.to_json

    render 'ds_common/example_done'
  end
end
