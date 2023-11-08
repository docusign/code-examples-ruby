# frozen_string_literal: true

class ESign::Eg004EnvelopeInfoService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:eSign4Step2
    envelope_api = create_envelope_api(args)
    envelope_api.get_envelope(args[:account_id], args[:envelope_id])
    #ds-snippet-end:eSign4Step2
  end
end
