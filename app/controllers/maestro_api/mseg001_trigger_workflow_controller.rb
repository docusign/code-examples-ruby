class MaestroApi::Mseg001TriggerWorkflowController < EgController
  before_action -> { check_auth('Maestro') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 1, 'Maestro') }

  def create
    args = {
      instance_name: params[:instance_name],
      signer_email: params[:signer_email],
      signer_name: params[:signer_name],
      cc_email: params[:cc_email],
      cc_name: params[:cc_name],
      workflow_id: session[:workflow_id],
      account_id: session[:ds_account_id],
      access_token: session[:ds_access_token],
      base_path: Rails.application.config.maestro_client_host
    }

    trigger_workflow_service = MaestroApi::Mseg001TriggerWorkflowService.new args
    workflow = trigger_workflow_service.get_workflow_definition
    results = trigger_workflow_service.trigger_workflow workflow

    session[:instance_id] = results.instance_id

    @title = @example['ExampleName']
    @message = format_string(@example['ResultsPageText'], results.instance_id)
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
      template_id: session[:workflow_template_id],
      account_id: session[:ds_account_id],
      access_token: session[:ds_access_token],
      base_path: Rails.application.config.maestro_client_host
    }

    trigger_workflow_service = MaestroApi::Mseg001TriggerWorkflowService.new args
    workflows = trigger_workflow_service.get_workflow_definitions

    if workflows.count.positive?
      sorted_workflows = workflows.value.sort_by(&:last_updated_date).reverse

      session[:workflow_id] = sorted_workflows[0].id if sorted_workflows
      session[:is_workflow_published] = true
    end

    unless session[:workflow_id]
      unless session[:workflow_template_id]
        @show_template_not_ok = true
        return render 'maestro_api/mseg001_trigger_workflow/get'
      end

      session[:workflow_id] = MaestroApi::Utils.new.create_workflow args
    end
    unless session[:is_workflow_published]
      consent_url = MaestroApi::Utils.new.publish_workflow args, session[:workflow_id]
      if consent_url
        additional_page_data = @example['AdditionalPage'].find { |p| p['Name'] == 'publish_workflow' }
        @title = @example['ExampleName']
        @message = additional_page_data['ResultsPageText']
        @consent_url = consent_url

        render 'maestro_api/mseg001_trigger_workflow/publish_workflow'
      end
    end
  rescue DocuSign_Maestro::ApiError => e
    @error_code = e.code || error['errorCode']
    if e.to_s == '403'
      @error_message = format_string(@manifest['SupportingTexts']['ContactSupportToEnableFeature'], 'Maestro')
      return render 'ds_common/error'
    end
    handle_error(e)
  end

  def publish
    args = {
      account_id: session[:ds_account_id],
      access_token: session[:ds_access_token],
      base_path: Rails.application.config.maestro_client_host
    }

    consent_url = MaestroApi::Utils.new.publish_workflow args, session[:workflow_id]

    if consent_url
      additional_page_data = @example['AdditionalPage'].find { |p| p['Name'] == 'publish_workflow' }
      @title = @example['ExampleName']
      @message = additional_page_data['ResultsPageText']
      @consent_url = consent_url

      return render 'maestro_api/mseg001_trigger_workflow/publish_workflow'
    end

    session[:is_workflow_published] = true
    render 'maestro_api/mseg001_trigger_workflow/get'
  rescue DocuSign_Maestro::ApiError => e
    @error_code = e.code || error['errorCode']
    if e.to_s == '403'
      @error_message = format_string(@manifest['SupportingTexts']['ContactSupportToEnableFeature'], 'Maestro')
      return render 'ds_common/error'
    end
    handle_error(e)
  end
end
