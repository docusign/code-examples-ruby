# frozen_string_literal: true

class ESign::Eg018GetEnvelopeCustomFieldDataService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:eSign19Step3
    create_envelope_api(args).list_custom_fields args[:account_id], args[:envelope_id]
    #ds-snippet-end:eSign19Step3
  end
end
