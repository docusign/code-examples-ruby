# frozen_string_literal: true

class ESign::Eg012Service
  include ApiCreator
  attr_reader :args

  def initialize(session, envelope_id, request)
    @args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      envelope_id: envelope_id,
      starting_view: request.params['starting_view'],
      ds_return_url: "#{Rails.application.config.app_url}/ds_common-return"
    }
  end

  def call
    # Call the worker method
    # More data validation would be a good idea here
    # Strip anything other than characters listed
    results = worker
  end

  private

  # ***DS.snippet.0.start
  def worker
    # Step 1. Create the NDSE view request object
    # Exceptions will be caught by the calling function
    view_request = DocuSign_eSign::ConsoleViewRequest.new({
                                                            returnUrl: args[:ds_return_url]
                                                          })
    if args[:starting_view] == 'envelope' && args[:envelope_id]
      view_request.envelope_id = args[:envelope_id]
    end
    # Step 2. Call the API method
    envelope_api = create_envelope_api(args)
    results = envelope_api.create_console_view args[:account_id], view_request
    { 'redirect_url' => results.url }
  end
  # ***DS.snippet.0.end
end