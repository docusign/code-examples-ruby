# frozen_string_literal: true

class ESign::Eg018GetEnvelopeCustomFieldDataService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:eSign18Step3
    create_envelope_api(args).list_custom_fields args[:account_id], args[:envelope_id]
    #ds-snippet-end:eSign18Step3
  end
end
