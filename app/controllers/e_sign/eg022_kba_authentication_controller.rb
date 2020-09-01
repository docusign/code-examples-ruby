# frozen_string_literal: true

class ESign::Eg022KbaAuthenticationController < EgController
  def create
    minimum_buffer_min = 3
    if check_token(minimum_buffer_min)
      begin
        results = ESign::Eg022Service.new(request, session).call
        @title = 'Envelope sent'
        @h1 = 'Envelope sent'
        @message = "The envelope has been created and sent!<br/>Envelope ID #{results.envelope_id}."
        render 'ds_common/example_done'
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
end
