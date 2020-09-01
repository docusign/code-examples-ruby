# frozen_string_literal: true

class ESign::Eg007Service
  include ApiCreator
  attr_reader :args, :document_id

  def initialize(request, session, envelope_id, envelope_documents)
    document_id = request.params['docSelect'].gsub(/([^\w \-\@\.\,])+/, '')
    @args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      envelope_id: envelope_id,
      'document_id' => document_id,
      'envelope_documents' => envelope_documents
    }
  end

  def call
    results = worker
  end

  private

  # ***DS.snippet.0.start
  def worker
    envelope_api = create_envelope_api(args)

    document_id = args['document_id']

    temp_file = envelope_api.get_document args[:account_id], document_id, args[:envelope_id]
    # Find the matching document information item
    doc_item = args['envelope_documents']['documents'].find { |item| item['document_id'] == document_id }

    doc_name = doc_item['name']
    has_pdf_suffix = doc_name.upcase.end_with? '.PDF'
    pdf_file = has_pdf_suffix

    # Add ".pdf" if it's a content or summary doc and doesn't already end in .pdf
    if doc_item['type'] == 'content' || (doc_item['type'] == 'summary' && !has_pdf_suffix)
      doc_name += '.pdf'
      pdf_file = true
    end
    # Add .zip as appropriate
    doc_name += '.zip' if doc_item['type'] == 'zip'
    # Return the file information
    mime_type = if pdf_file
                  'application/pdf'
                elsif doc_item['type'] == 'zip'
                  'application/zip'
                else
                  'application/octet-stream'
                end
    { 'mime_type' => mime_type, 'doc_name' => doc_name, 'data' => File.binread(temp_file.path) }
  end
end