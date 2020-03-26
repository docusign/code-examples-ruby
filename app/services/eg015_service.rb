# frozen_string_literal: true

class Eg015Service
  include ApiCreator
  attr_reader :args, :envelope_id

  def initialize(envelope_id, session)
    @args = {
      access_token: session['ds_access_token'],
      base_path: session['ds_base_path'],
      account_id: session['ds_account_id']
    }
    @envelope_id = envelope_id
  end

  def call
    results = worker
  end

  private

  # ***DS.snippet.0.start
  def worker
    # Step 1. List the envelope form data
    # The Envelopes::getEnvelopeFormData method has many options
    # See https://developers.docusign.com/esign-rest-api/reference/Envelopes/EnvelopeFormData/get
    # The get form data call requires an account ID and an envelope ID

    # Exceptions will be caught by the calling function
    results = create_envelope_api(args).get_form_data args[:account_id], envelope_id
  end
  # ***DS.snippet.0.end
end