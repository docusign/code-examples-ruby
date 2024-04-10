class MaestroApi::Mseg002CancelWorkflowController < EgController
  before_action -> { check_auth('Maestro') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 2, 'Maestro') }

  def create
    args = {
      workflow_id: session[:workflow_id],
      instance_id: session[:instance_id],
      account_id: session[:ds_account_id],
      access_token: session[:ds_access_token],
      base_path: Rails.application.config.maestro_client_host
    }

    results = MaestroApi::Mseg002CancelWorkflowService.new(args).cancel_workflow_instance

    @title = @example['ExampleName']
    @message = format_string(@example['ResultsPageText'], session[:instance_id])
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
    args = {
      workflow_id: session[:workflow_id],
      instance_id: session[:instance_id],
      account_id: session[:ds_account_id],
      access_token: session[:ds_access_token],
      base_path: Rails.application.config.maestro_client_host
    }

    state = MaestroApi::Mseg002CancelWorkflowService.new(args).get_instance_state
    @instance_ok = state.downcase == 'in progress'

    @workflow_id = session[:workflow_id]
    @instance_id = session[:instance_id]
  rescue DocuSign_Maestro::ApiError => e
    @error_code = e.code || error['errorCode']
    if e.to_s == '403'
      @error_message = format_string(@manifest['SupportingTexts']['ContactSupportToEnableFeature'], 'Maestro')
      return render 'ds_common/error'
    end
    handle_error(e)
  end
end
