# frozen_string_literal: true

class ESign::Eg033UnpausesSignatureWorkflowController < EgController
  before_action :check_auth

  def update
    results = ESign::Eg033UnpausesSignatureWorkflowService.new(session).call

    @envelop_id = results.to_hash[:envelopeId].to_s
    render 'e_sign/eg033_unpauses_signature_workflow/return'
  end

  private

  def check_auth
    minimum_buffer_min = 10
    token_ok = check_token(minimum_buffer_min)
    unless token_ok
      flash[:messages] = 'Sorry, you need to re-authenticate.'
      # We could store the parameters of the requested operation so it could be restarted automatically
      # But since it should be rare to have a token issue here, we'll make the user re-enter the form data after authentication
      redirect_to '/ds/mustAuthenticate'
    end
  end
end
