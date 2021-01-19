# frozen_string_literal: true

class ESign::Eg032PausesSignatureWorkflowController < EgController
  before_action :check_auth

  def create
    results = ESign::Eg032PausesSignatureWorkflowService.new(session, request).call

    @envelop_id = results.to_hash[:envelopeId].to_s
    session[:envelope_id] = @envelop_id

    render 'e_sign/eg032_pauses_signature_workflow/return'
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
