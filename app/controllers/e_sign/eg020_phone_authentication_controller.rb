# frozen_string_literal: true

class ESign::Eg020PhoneAuthenticationController < EgController
  before_action :check_auth
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 20) }

  def create
    envelope_args = {
      signer_email: param_gsub(params['signer_email']),
      signer_name: param_gsub(params['signer_name']),
      country_code: param_gsub(params['country_code']),
      phone_number: param_gsub(params['phone_number']),
      status: 'sent'
    }
    args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      envelope_args: envelope_args
    }

    phone_auth_service = ESign::Eg020PhoneAuthenticationService.new(args)

    # Retrieve the workflow id
    workflow_id = phone_auth_service.get_workflow
    session[:workflow_id] = workflow_id

    results = phone_auth_service.worker(workflow_id)

    if results.to_s == 'phone_auth_not_enabled'
      @error_code = 'IDENTITY_WORKFLOW_INVALID_ID'
      @error_message = 'The identity workflow ID specified is not valid.'
      @error_information = @example['CustomErrorTexts'][0]['ErrorMessage']
      render 'ds_common/error'
    else
      session[:envelope_id] = results.envelope_id
      @title = @example['ExampleName']
      @message = format_string(@example['ResultsPageText'], results.envelope_id)
      render 'ds_common/example_done'
    end
  end

  # ***DS.snippet.0.end
end
