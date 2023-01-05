# frozen_string_literal: true

class ESign::Eeg035ScheduledSendingController < EgController
  before_action -> { check_auth('eSignature') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 35, 'eSignature') }

  def create
    envelope_args = {
      signer_email: param_gsub(params['signer_email']),
      signer_name: param_gsub(params['signer_name']),
      resume_date: param_gsub(params['resume_date']),
      status: 'sent'
    }
    args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      envelope_args: envelope_args
    }
    results = ESign::Eg035ScheduledSendingService.new(args).worker
    session[:envelope_id] = results['envelope_id']
    @title = @example['ExampleName']
    @message = format_string(@example['ResultsPageText'], results['envelope_id'])
    render 'ds_common/example_done'
  rescue DocuSign_eSign::ApiError => e
    handle_error(e)
  end
end
