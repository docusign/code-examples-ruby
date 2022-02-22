# frozen_string_literal: true

class ESign::Eg032PausesSignatureWorkflowController < EgController
  before_action :check_auth

  def create
    signers = {
      signerEmail1: request['signerEmail1'],
      signerName1: request['signerName1'],
      signerEmail2: request['signerEmail2'],
      signerName2: request['signerName2']
    }
    args = {
      accountId: session['ds_account_id'],
      basePath: session['ds_base_path'],
      accessToken: session['ds_access_token'],
      status: 'sent'
    }

    results = ESign::Eg032PausesSignatureWorkflowService.new(args, signers).worker

    @envelop_id = results.to_hash[:envelopeId].to_s
    session[:envelope_id] = @envelop_id

    render 'e_sign/eg032_pauses_signature_workflow/return'
  end
end
