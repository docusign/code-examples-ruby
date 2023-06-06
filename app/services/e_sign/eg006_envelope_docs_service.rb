# frozen_string_literal: true

class ESign::Eg006EnvelopeDocsService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:eSign6Step3
    envelope_api = create_envelope_api(args)
    envelope_api.list_documents args[:account_id], args[:envelope_id]
    #ds-snippet-end:eSign6Step3
  end
end
