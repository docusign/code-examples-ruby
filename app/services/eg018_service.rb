# frozen_string_literal: true

class Eg018Service
  include ApiCreator
  attr_reader :args

  def initialize(session, envelope_id)
    @args = {
      access_token: session['ds_access_token'],
      base_path: session['ds_base_path'],
      account_id: session['ds_account_id'],
      envelope_id: envelope_id
    }
  end

  def call
    # Step 3. Call the eSignature REST API
    results = create_envelope_api(args).list_custom_fields args[:account_id], args[:envelope_id]
  end
end
