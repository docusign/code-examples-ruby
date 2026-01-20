# frozen_string_literal: true

class ESign::Eg006EnvelopeDocsService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:eSign6Step3
    envelope_api = create_envelope_api(args)
    results, _status, headers = envelope_api.list_documents_with_http_info args[:account_id], args[:envelope_id]

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:eSign6Step3

    results
  end
end
