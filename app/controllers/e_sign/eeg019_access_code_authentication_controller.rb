# frozen_string_literal: true

class ESign::Eeg019AccessCodeAuthenticationController < EgController
  before_action -> { check_auth('eSignature') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 19, 'eSignature') }

  def create
    # ***DS.snippet.0.start
    envelope_args = {
      signer_email: param_gsub(params['signerEmail']),
      signer_name: param_gsub(params['signerName']),
      accessCode: params['accessCode'],
      status: 'sent'
    }
    args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      envelope_args: envelope_args
    }

    results = ESign::Eg019AccessCodeAuthenticationService.new(args).worker
    session[:envelope_id] = results.envelope_id

    @title = @example['ExampleName']
    @message = format_string(@example['ResultsPageText'], results.envelope_id)
    render 'ds_common/example_done'
  rescue DocuSign_eSign::ApiError => e
    handle_error(e)
  end
  # ***DS.snippet.0.end
end
