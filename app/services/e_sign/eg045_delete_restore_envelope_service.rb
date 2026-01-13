# frozen_string_literal: true

class ESign::Eg045DeleteRestoreEnvelopeService
  include ApiCreator

  def delete_envelope(args)
    #ds-snippet-start:eSign45Step2
    folders_api = create_folders_api(args)
    #ds-snippet-end:eSign45Step2

    #ds-snippet-start:eSign45Step3
    folders_request = DocuSign_eSign::FoldersRequest.new
    folders_request.envelope_ids = [args[:envelope_id]]
    #ds-snippet-end:eSign45Step3

    #ds-snippet-start:eSign45Step4
    results, _status, headers = folders_api.move_envelopes_with_http_info(args[:account_id], args[:delete_folder_id], folders_request)

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:eSign45Step4

    results
  end

  def move_envelope_to_folder(args)
    folders_api = create_folders_api(args)

    #ds-snippet-start:eSign45Step6
    folders_request = DocuSign_eSign::FoldersRequest.new
    folders_request.envelope_ids = [args[:envelope_id]]
    folders_request.from_folder_id = args[:from_folder_id]

    results, _status, headers = folders_api.move_envelopes_with_http_info(args[:account_id], args[:folder_id], folders_request)

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:eSign45Step6

    results
  end

  def get_folders(args)
    folders_api = create_folders_api(args)

    #ds-snippet-start:eSign45Step5
    results, _status, headers = folders_api.list_with_http_info(args[:account_id])

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:eSign45Step5

    results
  end
end
