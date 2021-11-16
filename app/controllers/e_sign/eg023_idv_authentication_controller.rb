# frozen_string_literal: true

class ESign::Eg023IdvAuthenticationController < EgController
  def create
    minimum_buffer_min = 3
    if check_token(minimum_buffer_min)
      begin
        results = ESign::Eg023IdvAuthenticationService.new(request, session).call
        if results.to_s == "idv_not_enabled"
          @error_code = "IDENTITY_WORKFLOW_INVALID_ID"
          @error_message = "The identity workflow ID specified is not valid."
          @error_information = "Please contact <a target='_blank' rel='noopener noreferrer' href='https://support.docusign.com/'>Support</a> to enable ID verification in your account."
          render 'ds_common/error'

        else
          @title = 'Envelope sent'
          @h1 = 'Envelope sent'
          @message = "The envelope has been created and sent!<br/>Envelope ID #{results.envelope_id}."
          render 'ds_common/example_done'
        end
      rescue DocuSign_eSign::ApiError => e
        error = JSON.parse e.response_body
        @error_code = error['errorCode']
        @error_message = error['message']
        render 'ds_common/error'
      end
    else
      flash[:messages] = 'Sorry, you need to re-authenticate.'
      # We could store the parameters of the requested operation so it could be restarted
      # automatically. But since it should be rare to have a token issue here,
      # we'll make the user re-enter the form data after authentication
      redirect_to '/'
    end
  end

  # ***DS.snippet.0.end
end
