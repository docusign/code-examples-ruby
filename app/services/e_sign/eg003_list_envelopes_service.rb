# frozen_string_literal: true

class ESign::Eg003ListEnvelopesService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    # List the envelopes
    # The Envelopes::listStatusChanges method has many options
    # See https://developers.docusign.com/esign-rest-api/reference/Envelopes/Envelopes/listStatusChange#
    # The list status changes call requires at least a from_date OR
    # a set of envelopeIds. Here we filter using a from_date.
    # Here we set the from_date to filter envelopes for the last month
    # Use ISO 8601 date format
    #ds-snippet-start:eSign3Step2
    envelope_api = create_envelope_api(args)
    options = DocuSign_eSign::ListStatusChangesOptions.new
    options.from_date = (Date.today - 30).strftime('%Y-%m-%d')
    # Exceptions will be caught by the calling function
    results, _status, headers = envelope_api.list_status_changes_with_http_info args[:account_id], options

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:eSign3Step2

    results
  end
end
