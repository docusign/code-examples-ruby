# frozen_string_literal: true

class ESign::Eg015GetEnvelopeTabDataService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  # ***DS.snippet.0.start
  def worker
    # Step 3. Call the eSignature REST API
    # The Envelopes::getEnvelopeFormData method has many options
    # See https://developers.docusign.com/docs/esign-rest-api/reference/Envelopes/EnvelopeFormData/get/
    # The get form data call requires an account ID and an envelope ID

    # Exceptions will be caught by the calling function
    create_envelope_api(args).get_form_data args[:account_id], args[:envelope_id]
  end
  # ***DS.snippet.0.end
end
