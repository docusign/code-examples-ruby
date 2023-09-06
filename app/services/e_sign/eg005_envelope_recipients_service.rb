# frozen_string_literal: true

class ESign::Eg005EnvelopeRecipientsService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:eSign5Step2
    envelope_api = create_envelope_api(args)
    envelope_api.list_recipients args[:account_id], args[:envelope_id]
    #ds-snippet-end:eSign5Step2
  end
end
