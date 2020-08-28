# frozen_string_literal: true

class ESign::Eg006EnvelopeDocsController < EgController
  def create
    minimum_buffer_min = 3
    envelope_id = session[:envelope_id]
    token_ok = check_token(minimum_buffer_min)

    if token_ok && envelope_id
      begin
        results = ESign::Eg006Service.new(request, session, envelope_id).call

        @title = 'Envelope documents list'
        @h1 = 'List the envelope\'s documents'
        @message = 'Results from the EnvelopeDocuments::list method:'
        @json = results.to_json.to_json
        render 'ds_common/example_done'
      rescue DocuSign_eSign::ApiError => e
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
    elsif !envelope_id
      @title = 'Envelope recipient information'
      @envelope_ok = false
    end
  end
end
