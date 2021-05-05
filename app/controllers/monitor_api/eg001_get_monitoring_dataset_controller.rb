class MonitorApi::Eg001GetMonitoringDatasetController < EgController
  before_action :check_auth

  def create
    results = MonitorApi::Eg001GetMonitoringDatasetService.new(session, nil).call

    @title = "Monitoring data result"
    @h1 = "Monitoring data result"
    @message = "Results from DataSet:GetStreamForDataset method:"
    @json = results.to_json.to_json

    render 'ds_common/example_done'
  end

  private

  def check_auth
    minimum_buffer_min = 10
    token_ok = check_token(minimum_buffer_min)
    unless token_ok
      flash[:messages] = 'Sorry, you need to re-authenticate.'
      # We could store the parameters of the requested operation so it could be restarted automatically
      # But since it should be rare to have a token issue here, we'll make the user re-enter the form data after authentication
      redirect_to '/ds/mustAuthenticate'
    end
  end
end
