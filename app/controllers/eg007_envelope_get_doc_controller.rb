class Eg007EnvelopeGetDocController < EgController
  skip_before_action :verify_authenticity_token
  def eg_name
    "eg007"
  end
  def get_file_name
    File.basename __FILE__
  end

  def create
    minimum_buffer_min = 3
    envelope_id = session[:envelope_id]? session[:envelope_id] : nil
    envelope_documents = session[:envelope_documents] ? session[:envelope_documents] : false
    token_ok = check_token(minimum_buffer_min)

    if token_ok && envelope_id && envelope_documents
      # Call the worker method
      # More data validation would be a good idea here
      document_id = request.params['docSelect'].gsub(/([^\w \-\@\.\,])+/, '')
      args = {
          'account_id' => session['ds_account_id'],
          'base_path' => session['ds_base_path'],
          'access_token' => session['ds_access_token'],
          'envelope_id' => envelope_id,
          'document_id' => document_id,
          'envelope_documents' => envelope_documents
      }
      begin
        results = worker args
        send_data results['data'], filename: results['doc_name'],
                  content_type: results['mime_type'],
                  disposition: "attachment; filename=\"#{results['doc_name']}\""
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
    elsif !envelope_id || !envelope_documents
      @title = 'Download an envelope\'s document'
      @envelope_ok = false
      @documents_ok = false
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

    document_id = args['document_id']

    temp_file = envelope_api.get_document args['account_id'], document_id, args['envelope_id']
    # find the matching document information item
    doc_item = args['envelope_documents']['documents'].find { |item| item['document_id'] == document_id }

    doc_name = doc_item['name']
    has_pdf_suffix = doc_name.upcase.end_with? '.PDF'
    pdf_file = has_pdf_suffix

    # Add ".pdf" if it's a content or summary doc and doesn't already end in .pdf
    if doc_item["type"] == "content" || (doc_item["type"] == "summary" && !has_pdf_suffix)
        doc_name += ".pdf"
        pdf_file = true
    end
    # Add .zip as appropriate
    if doc_item["type"] == "zip"
        doc_name += ".zip"
    end
    # Return the file information
    if pdf_file
      mime_type = 'application/pdf'
    elsif doc_item["type"] == 'zip'
      mime_type = 'application/zip'
    else
      mime_type = 'application/octet-stream'
    end

    {'mime_type' => mime_type, 'doc_name' => doc_name, 'data' => File.binread(temp_file.path)}
  end
  # ***DS.snippet.0.end
end