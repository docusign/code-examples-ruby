# frozen_string_literal: true

class Eg011EmbeddedSendingController < EgController
  def create
    minimum_buffer_min = 10
    token_ok = check_token(minimum_buffer_min)

    if token_ok
      begin
        results = ::Eg011Service.new(request, session).call
        redirect_to results['redirect_url']
      rescue  DocuSign_eSign::ApiError => e
        error = JSON.parse e.response_body
        @error_code = error['errorCode']
        @error_message = error['message']
        render 'ds_common/error'
      end
    elsif !token_ok
      flash[:messages] = 'Sorry, you need to re-authenticate.'
      # We could store the parameters of the requested operation
      # so it could be restarted automatically.
      # But since it should be rare to have a token issue here,
      # we'll make the user re-enter the form data after
      # authentication.
      redirect_to '/ds/mustAuthenticate'
    elsif !template_id
      @title = 'Use a template to send an envelope'
      @template_ok = false
    end
  end
end
