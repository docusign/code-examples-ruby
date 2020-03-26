# frozen_string_literal: true

class Eg012EmbeddedConsoleController < EgController
  def create
    minimum_buffer_min = 3
    envelope_id = session[:envelope_id]
    token_ok = check_token(minimum_buffer_min)

    if token_ok
      begin
        results = ::Eg012Service.new(session, envelope_id, request).call
        redirect_to results['redirect_url']
      rescue DocuSign_eSign::ApiError => e
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
