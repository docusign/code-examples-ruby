# frozen_string_literal: true

class Eg023IdvAuthenticationController < EgController
  def create
    minimum_buffer_min = 3
    if check_token(minimum_buffer_min)
      begin
        results = ::Eg023Service.new(request, session).call
        if results.to_s == 'needs_idv_activated'
          @title = 'Error'
          @h1 = 'Error'
          @message = 'Please activate IDV on your account to use this example.'
          render 'ds_common/example_done'
          
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
