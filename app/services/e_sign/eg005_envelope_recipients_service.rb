# frozen_string_literal: true

class ESign::Eg005EnvelopeRecipientsService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:eSign5Step2
    envelope_api = create_envelope_api(args)
    results, _status, headers = envelope_api.list_recipients_with_http_info args[:account_id], args[:envelope_id]

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:eSign5Step2

    results
  end
end
