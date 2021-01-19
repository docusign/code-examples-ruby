# frozen_string_literal: true

class ESign::Eg034UseConditionalRecipientsController < EgController
  before_action :check_auth

  def create
    begin
      results = ESign::Eg034UseConditionalRecipientsService.new(session, request).call
      @envelop_id = results.to_hash[:envelopeId].to_s
      render 'e_sign/eg034_use_conditional_recipients/return'
    rescue DocuSign_eSign::ApiError => e
      error = JSON.parse e.response_body
      @error_code = error['errorCode']
      if error['errorCode']["WORKFLOW_UPDATE_RECIPIENTROUTING_NOT_ALLOWED"]
        @error_message = "Update to the workflow with recipient routing is not allowed for your account!"
        @error_information = "Please contact with our <a href='https://developers.docusign.com/support/' target='_blank'>support team</a> to resolve this issue."
      else 
        @error_message = error['message']
      end
      render 'ds_common/error'
    end
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
