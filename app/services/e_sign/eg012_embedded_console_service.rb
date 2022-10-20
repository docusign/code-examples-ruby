# frozen_string_literal: true

class ESign::Eg012EmbeddedConsoleService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  # ***DS.snippet.0.start
  def worker
    # Step 1. Create the NDSE view request object
    # Exceptions will be caught by the calling function
    view_request = DocuSign_eSign::ConsoleViewRequest.new({
                                                            returnUrl: args[:ds_return_url]
                                                          })
    view_request.envelope_id = args[:envelope_id] if args[:starting_view] == 'envelope' && args[:envelope_id]
    # Step 2. Call the API method
    envelope_api = create_envelope_api(args)
    results = envelope_api.create_console_view args[:account_id], view_request
    { 'redirect_url' => results.url }
  end
  # ***DS.snippet.0.end
end
