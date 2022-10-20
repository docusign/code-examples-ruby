# frozen_string_literal: true

class ESign::Eg006EnvelopeDocsService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  # ***DS.snippet.0.start
  def worker
    envelope_api = create_envelope_api(args)
    envelope_api.list_documents args[:account_id], args[:envelope_id]
  end
  # ***DS.snippet.0.end
end
