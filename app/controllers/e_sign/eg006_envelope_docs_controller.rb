# frozen_string_literal: true

class ESign::Eg006EnvelopeDocsController < EgController
  before_action :check_auth
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 6) }

  def create
    envelope_id = session[:envelope_id]

    if envelope_id
      begin
        args = {
          account_id: session['ds_account_id'],
          base_path: session['ds_base_path'],
          access_token: session['ds_access_token'],
          envelope_id: envelope_id
        }

        standart_doc_items = [
          { name: 'Combined', type: 'content', document_id: 'combined' },
          { name: 'Zip archive', type: 'zip', document_id: 'archive' },
          { name: 'PDF Portfolio', type: 'content', document_id: 'portfolio' }
        ]

        results = ESign::Eg006EnvelopeDocsService.new(args).worker
        # The certificate of completion is named "summary"
        # We give it a better name below.
        envelope_doc_items = results.envelope_documents.map do |doc|
          new = if doc.document_id == 'certificate'
                  { document_id: doc.document_id, name: 'Certificate of completion', type: doc.type }
                else
                  { document_id: doc.document_id, name: doc.name, type: doc.type }
                end
          new
        end

        documents = standart_doc_items + envelope_doc_items
        envelope_documents = { envelope_id: args[:envelope_id], documents: documents }
        session[:envelope_documents] = envelope_documents

        @title = @example['ExampleName']
        @message = @example['ResultsPageText']
        @json =  results.to_json.to_json
        render 'ds_common/example_done'
      rescue DocuSign_eSign::ApiError => e
        handle_error(e)
      end
    elsif !envelope_id
      @title = @example['ExampleName']
      @envelope_ok = false
    end
  end
end
