class MonitorApi::Meg002PostWebQueryController < EgController
  before_action -> { check_auth('Monitor') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 2, 'Monitor') }

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

    @title = @example['ExampleName']

    if results != "Monitor not enabled"
      @message = @example['ResultsPageText']
      @json = results.to_json.to_json
    else
      @message = "You do not have Monitor enabled for your account, follow <a target='_blank' href='https://developers.docusign.com/docs/monitor-api/how-to/enable-monitor/'>How to enable Monitor for your account</a> to get it enabled."
    end

    render 'ds_common/example_done'
  end
end