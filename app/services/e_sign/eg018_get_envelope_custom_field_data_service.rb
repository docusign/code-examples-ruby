# frozen_string_literal: true

class ESign::Eg018GetEnvelopeCustomFieldDataService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:eSign18Step3
    results, _status, headers = create_envelope_api(args).list_custom_fields_with_http_info args[:account_id], args[:envelope_id]

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:eSign18Step3

    results
  end
end
