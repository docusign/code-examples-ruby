# frozen_string_literal: true

class ESign::Eg005EnvelopeRecipientsService
  attr_reader :args
  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    envelope_api = create_envelope_api(args)
    results = envelope_api.list_recipients args[:account_id], args[:envelope_id]
  end
end
