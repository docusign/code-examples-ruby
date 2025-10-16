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
    folders_api.move_envelopes(args[:account_id], args[:delete_folder_id], folders_request)
    #ds-snippet-end:eSign45Step4
  end

  def move_envelope_to_folder(args)
    folders_api = create_folders_api(args)

    #ds-snippet-start:eSign45Step6
    folders_request = DocuSign_eSign::FoldersRequest.new
    folders_request.envelope_ids = [args[:envelope_id]]
    folders_request.from_folder_id = args[:from_folder_id]

    folders_api.move_envelopes(args[:account_id], args[:folder_id], folders_request)
    #ds-snippet-end:eSign45Step6
  end

  def get_folders(args)
    folders_api = create_folders_api(args)

    #ds-snippet-start:eSign45Step5
    folders_api.list(args[:account_id])
    #ds-snippet-end:eSign45Step5
  end
end
