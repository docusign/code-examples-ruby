# frozen_string_literal: true

class ESign::Eg004Service
  include ApiCreator
  attr_reader :args

  def initialize(session, envelope_id)
    @args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      envelope_id: envelope_id
    }
  end

  def call
    envelope_api = create_envelope_api(args)
    results = envelope_api.get_envelope(args[:account_id], args[:envelope_id])
  end
end
