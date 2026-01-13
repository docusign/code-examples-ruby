# frozen_string_literal: true

class ESign::Eg004EnvelopeInfoService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:eSign4Step2
    envelope_api = create_envelope_api(args)
    results, _status, headers = envelope_api.get_envelope_with_http_info(args[:account_id], args[:envelope_id])

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:eSign4Step2

    results
  end
end
