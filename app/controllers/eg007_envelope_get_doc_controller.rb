# frozen_string_literal: true

class Eg007EnvelopeGetDocController < EgController
  def create
    minimum_buffer_min = 3
    envelope_id = session[:envelope_id]
    envelope_documents = session[:envelope_documents]
    token_ok = check_token(minimum_buffer_min)
    if token_ok && envelope_id && envelope_documents
      begin
        results = ::Eg007Service.new(request, session, envelope_id, envelope_documents).call
        send_data results['data'], filename: results['doc_name'],
                                   content_type: results['mime_type'],
                                   disposition: "attachment; filename=\"#{results['doc_name']}\""
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
    elsif !envelope_id || !envelope_documents
      @title = 'Download an envelope\'s document'
      @envelope_ok = false
      @documents_ok = false
    end
  end
end
