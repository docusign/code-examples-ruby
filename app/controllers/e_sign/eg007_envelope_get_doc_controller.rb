# frozen_string_literal: true

class ESign::Eg007EnvelopeGetDocController < EgController
  before_action :check_auth

  def create
    envelope_id = session[:envelope_id]
    envelope_documents = session[:envelope_documents]
    if envelope_id && envelope_documents
      begin
        document_id = param_gsub(params['docSelect'])
        args = {
          account_id: session['ds_account_id'],
          base_path: session['ds_base_path'],
          access_token: session['ds_access_token'],
          envelope_id: envelope_id,
          document_id: document_id,
          envelope_documents: envelope_documents
        }
        results = ESign::Eg007EnvelopeGetDocService.new(args).worker
        send_data results['data'], filename: results['doc_name'],
                                   content_type: results['mime_type'],
                                   disposition: "attachment; filename=\"#{results['doc_name']}\""
      rescue DocuSign_eSign::ApiError => e
        handle_error(e)
      end
    elsif !envelope_id || !envelope_documents
      @title = 'Download an envelope\'s document'
      @envelope_ok = false
      @documents_ok = false
    end
  end
end
