class Eg006EnvelopeDocsController < EgController
  skip_before_action :verify_authenticity_token
  def eg_name
    "eg006"
  end
  def get_file_name
    File.basename __FILE__
  end

  def create
    minimum_buffer_min = 3
    envelope_id = session[:envelope_id]? session[:envelope_id] : nil
    token_ok = check_token(minimum_buffer_min)

    if token_ok && envelope_id
      # 2. Call the worker method
      args = {
          'account_id' => session['ds_account_id'],
          'base_path' => session['ds_base_path'],
          'access_token' => session['ds_access_token'],
          'envelope_id' => envelope_id
      }

      begin
        results = worker args
        # Save the envelopeId and its list of documents in the session so
        # they can be used in example 7 (download a document)
        standard_doc_items = [
            {'name' => 'Combined'   , 'type' => 'content', 'document_id' => 'combined'},
            {'name' => 'Zip archive', 'type' => 'zip'    , 'document_id' => 'archive'}
        ]
        # The certificate of completion is named "summary".
        # We give it a better name below.
        envelope_doc_items = results.envelope_documents.map do |doc|
          if doc.document_id == "certificate"
            new = {'document_id' => doc.document_id, 'name' => "Certificate of completion",
                    'type' => doc.type}
          else
            new = {'document_id' => doc.document_id, 'name' => doc.name, 'type' => doc.type}
          end

          new
        end

        documents = standard_doc_items + envelope_doc_items
        envelope_documents =  {'envelope_id' => envelope_id, 'documents' => documents}
        session[:envelope_documents] = envelope_documents
        @title = 'Envelope documents list'
        @h1 = 'List the envelope\'s documents'
        @message = 'Results from the EnvelopeDocuments::list method:'
        @json = results.to_json.to_json
        render 'ds_common/example_done'
      rescue DocuSign_eSign::ApiError => e
        error = JSON.parse e.response_body
        @error_code = error['errorCode']
        @error_message = error['message']
        render "ds_common/error"
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

  # ***DS.snippet.0.start
  def worker args
    # 1. call API method
    # Exceptions will be caught by the calling function
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args['base_path']
    api_client = DocuSign_eSign::ApiClient.new configuration
    api_client.default_headers["Authorization"] = "Bearer #{args['access_token']}"
    envelope_api = DocuSign_eSign::EnvelopesApi.new api_client
    results = envelope_api.list_documents args['account_id'], args['envelope_id']
    results
  end
  # ***DS.snippet.0.end
end