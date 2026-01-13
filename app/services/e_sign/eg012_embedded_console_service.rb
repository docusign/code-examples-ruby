# frozen_string_literal: true

class ESign::Eg012EmbeddedConsoleService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    # Step 1. Create the NDSE view request object
    # Exceptions will be caught by the calling function
    #ds-snippet-start:eSign12Step2
    view_request = DocuSign_eSign::ConsoleViewRequest.new({
                                                            returnUrl: args[:ds_return_url]
                                                          })
    view_request.envelope_id = args[:envelope_id] if args[:starting_view] == 'envelope' && args[:envelope_id]
    # Step 2. Call the API method
    envelope_api = create_envelope_api(args)
    results, _status, headers = envelope_api.create_console_view_with_http_info args[:account_id], view_request

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end

    #ds-snippet-end:eSign12Step2
    { 'redirect_url' => results.url }
  end
end
