# frozen_string_literal: true

class ESign::Eeg020PhoneAuthenticationController < EgController
  before_action -> { check_auth('eSignature') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 20, 'eSignature') }

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

    if Rails.application.config.signer_email == envelope_args[:signer_email]
      @error_code = 400
      @error_message = @manifest['SupportingTexts']['IdenticalEmailsNotAllowedErrorMessage']
      return render 'ds_common/error'
    end

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

  def get
    enableCFR = ESign::GetDataService.new(session[:ds_access_token], session[:ds_base_path]).cfr?(session[:ds_account_id])
    if enableCFR == 'enabled'
      session[:status_cfr] = 'enabled'
      @title = 'Not CFR Part 11 compatible'
      @error_information = @manifest['SupportingTexts']['CFRError']
      render 'ds_common/error'
    end
    super
  end
end
