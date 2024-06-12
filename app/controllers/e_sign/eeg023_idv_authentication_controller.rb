# frozen_string_literal: true

class ESign::Eeg023IdvAuthenticationController < EgController
  before_action -> { check_auth('eSignature') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 23, 'eSignature') }

  def create
    envelope_args = {
      signer_email: param_gsub(params['signerEmail']),
      signer_name: param_gsub(params['signerName']),
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

    results = ESign::Eg023IdvAuthenticationService.new(args).worker

    if results.to_s == 'idv_not_enabled'
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
  rescue DocuSign_eSign::ApiError => e
    error = JSON.parse e.response_body
    @error_code = error['errorCode']
    @error_message = error['message']
    render 'ds_common/error'
  end

  # ***DS.snippet.0.end
end
