# frozen_string_literal: true

class Eg003Service
  include ApiCreator
  attr_reader :args

  def initialize(session)
     @args = {
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token]
    }
  end

  def call
    # Step 1. List the envelopes
    # The Envelopes::listStatusChanges method has many options
    # See https://developers.docusign.com/esign-rest-api/reference/Envelopes/Envelopes/listStatusChange#
    # The list status changes call requires at least a from_date OR
    # a set of envelopeIds. Here we filter using a from_date.
    # Here we set the from_date to filter envelopes for the last month
    # Use ISO 8601 date format
    envelope_api = create_envelope_api(args)
    options = DocuSign_eSign::ListStatusChangesOptions.new
    options.from_date = (Date.today - 30).strftime('%Y/%m/%d')
    # Exceptions will be caught by the calling function
    results = envelope_api.list_status_changes args[:account_id], options
  end
end