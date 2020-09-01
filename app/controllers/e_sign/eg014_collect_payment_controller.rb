# frozen_string_literal: true

class ESign::Eg014CollectPaymentController < EgController
  def create
    minimum_buffer_min = 10
    token_ok = check_token(minimum_buffer_min)

    if token_ok
      begin
        results = ESign::Eg014Service.new(request, session).call
        @title = 'Envelope sent'
        @h1 = 'Envelope sent'
        @message = "The order form envelope has been created and sent!<br/>
           Envelope ID #{results[:envelope_id]}"
        render 'ds_common/example_done'
      rescue  DocuSign_eSign::ApiError => e
        error = JSON.parse e.response_body
        @error_code = error['errorCode']
        @error_message = error['message']
        render 'ds_common/error'
      end
    else
      flash[:messages] = 'Sorry, you need to re-authenticate.'
      # We could store the parameters of the requested operation
      # so it could be restarted automatically.
      # But since it should be rare to have a token issue here,
      # we'll make the user re-enter the form data after
      # authentication.
      redirect_to '/ds/mustAuthenticate'
    end
  end
end
