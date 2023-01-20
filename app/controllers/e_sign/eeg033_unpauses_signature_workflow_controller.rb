# frozen_string_literal: true

class ESign::Eeg033UnpausesSignatureWorkflowController < EgController
  before_action -> { check_auth('eSignature') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 33, 'eSignature') }

  def update
    args = {
      accountId: session['ds_account_id'],
      basePath: session['ds_base_path'],
      accessToken: session['ds_access_token'],
      envelopeId: session['envelope_id'],
      status: 'in_progress'
    }

    results = ESign::Eg033UnpausesSignatureWorkflowService.new(args).worker

    @envelop_id = results.to_hash[:envelopeId].to_s
    render 'e_sign/eg033_unpauses_signature_workflow/return'
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
