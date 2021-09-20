# frozen_string_literal: true

class ESign::Eg020PhoneAuthenticationController < EgController
  def create
    minimum_buffer_min = 3
    if check_token(minimum_buffer_min)
      begin
        results = ESign::Eg020PhoneAuthenticationService.new(request, session).call
        session[:envelope_id] = results.envelope_id
        @title = 'Require Phone Authentication for a Recipient'
        @h1 = 'Require Phone Authentication for a Recipient'
        @message = "The envelope has been created and sent!<br/>Envelope ID #{results.envelope_id}."
        render 'ds_common/example_done'
      rescue DocuSign_eSign::ApiError => e
        error = JSON.parse e.response_body
        @error_code = error['errorCode']
        @error_message = error['message']
        if error['errorCode']["IDENTITY_WORKFLOW_INVALID_ID"]
          @error_information = "Please contact <a target='_blank' rel='noopener noreferrer' href='https://support.docusign.com/'>Support</a> to enable recipient phone authentication in your account."
        end
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
