# frozen_string_literal: true

class ESign::Eg033UnpausesSignatureWorkflowController < EgController
  before_action :check_auth

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
end
