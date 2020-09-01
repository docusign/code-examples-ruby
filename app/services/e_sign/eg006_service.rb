# frozen_string_literal: true

class ESign::Eg006Service
  include ApiCreator
  attr_reader :args, :standart_doc_items, :session

  def initialize(_request, session, envelope_id)
    @args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      envelope_id: envelope_id
    }
    @session = session
    # Save the envelopeId and its list of documents in the session so
    # they can be used in example 7 (download a document)
    @standart_doc_items = [
      { name: 'Combined', type: 'content', document_id: 'combined' },
      { name: 'Zip archive', type: 'zip', document_id: 'archive' }
    ]
  end

  def call
    results = worker
    # The certificate of completion is named "summary"
    # We give it a better name below.
    envelope_doc_items = results.envelope_documents.map do |doc|
      if doc.document_id == 'certificate'
        new = { document_id: doc.document_id, name: 'Certificate of completion', type: doc.type }
      else
        new = { document_id: doc.document_id, name: doc.name, type: doc.type }
      end
      new
    end

    documents = standart_doc_items + envelope_doc_items
    envelope_documents = { envelope_id: args[:envelope_id], documents: documents }
    session[:envelope_documents] = envelope_documents
    results
  end

  private

  # ***DS.snippet.0.start
  def worker
    envelope_api = create_envelope_api(args)
    results = envelope_api.list_documents args[:account_id], args[:envelope_id]
    results
  end
  # ***DS.snippet.0.end
end