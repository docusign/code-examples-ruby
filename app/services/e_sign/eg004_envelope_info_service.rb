# frozen_string_literal: true

class ESign::Eg004EnvelopeInfoService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    envelope_api = create_envelope_api(args)
    envelope_api.get_envelope(args[:account_id], args[:envelope_id])
  end
end
