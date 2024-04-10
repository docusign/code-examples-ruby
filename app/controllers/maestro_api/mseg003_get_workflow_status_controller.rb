class MaestroApi::Mseg003GetWorkflowStatusController < EgController
  before_action -> { check_auth('Maestro') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 3, 'Maestro') }

  def create
    args = {
      workflow_id: session[:workflow_id],
      instance_id: session[:instance_id],
      account_id: session[:ds_account_id],
      access_token: session[:ds_access_token],
      base_path: Rails.application.config.maestro_client_host
    }

    results = MaestroApi::Mseg003GetWorkflowStatusService.new(args).get_instance_state

    @title = @example['ExampleName']
    @message = format_string(@example['ResultsPageText'], results.instance_state)
    @json = results.to_json.to_json

    render 'ds_common/example_done'
  rescue DocuSign_Maestro::ApiError => e
    @error_code = e.code || error['errorCode']
    if e.to_s == '403'
      @error_message = format_string(@manifest['SupportingTexts']['ContactSupportToEnableFeature'], 'Maestro')
      return render 'ds_common/error'
    end
    handle_error(e)
  end

  def get
    @workflow_id = session[:workflow_id]
    @instance_id = session[:instance_id]
  end
end
