# frozen_string_literal: true

class ESign::Eg007EnvelopeGetDocService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:eSign7Step3
    envelope_api = create_envelope_api(args)

    document_id = args[:document_id]

    temp_file, _status, headers = envelope_api.get_document_with_http_info args[:account_id], document_id, args[:envelope_id]

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:eSign7Step3
    # Find the matching document information item
    doc_item = args[:envelope_documents]['documents'].find { |item| item['document_id'] == document_id }

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
