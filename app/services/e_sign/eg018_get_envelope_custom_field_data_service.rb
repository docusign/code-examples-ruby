# frozen_string_literal: true

class ESign::Eg018GetEnvelopeCustomFieldDataService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    # Step 3. Call the eSignature REST API
    create_envelope_api(args).list_custom_fields args[:account_id], args[:envelope_id]
  end
end
