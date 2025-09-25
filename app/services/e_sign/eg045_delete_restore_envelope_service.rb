# frozen_string_literal: true

class ESign::Eg045DeleteRestoreEnvelopeService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def move_envelope
    #ds-snippet-start:eSign45Step2
    folders_api = create_folders_api(args)
    #ds-snippet-end:eSign45Step2

    #ds-snippet-start:eSign45Step3
    folders_request = DocuSign_eSign::FoldersRequest.new
    folders_request.envelope_ids = [args[:envelope_id]]
    folders_request.from_folder_id = args[:from_folder_id] unless args[:from_folder_id].nil?
    #ds-snippet-end:eSign45Step3

    #ds-snippet-start:eSign45Step4
    folders_api.move_envelopes(args[:account_id], args[:folder_id], folders_request)
    #ds-snippet-end:eSign45Step4
  end
end
