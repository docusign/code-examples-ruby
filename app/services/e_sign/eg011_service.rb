# frozen_string_literal: true

class ESign::Eg011Service
  include ApiCreator
  attr_reader :args, :request, :session

  def initialize(request, session)
    envelope_args = {
      signer_email: request.params['signerEmail'].gsub(/([^\w \-\@\.\,])+/, ''),
      signer_name: request.params['signerName'].gsub(/([^\w \-\@\.\,])+/, ''),
      cc_email: request.params['ccEmail'].gsub(/([^\w \-\@\.\,])+/, ''),
      cc_name: request.params['ccName'].gsub(/([^\w \-\@\.\,])+/, '')
    }

    @args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      starting_view: request.params['starting_view'].gsub(/([^\w \-\@\.\,])+/, ''),
      envelope_args: envelope_args,
      ds_return_url: "#{Rails.application.config.app_url}/ds_common-return"
    }

    @session = session
    @request = request
  end

  def call
    # Step 1. Create the envelope as a draft using eg002's worker
    # Exceptions will be caught by the calling function
    results = ::Eg002Service.new(session, request, 'created').call
    envelope_id = results['envelope_id']
    # Step 2. Create the sender view
    view_request = DocuSign_eSign::ReturnUrlRequest.new({ returnUrl: args[:ds_return_url] })
    envelope_api = create_envelope_api(args)
    results = envelope_api.create_sender_view args[:account_id], envelope_id, view_request
    # Switch to the Recipients/Documents view if requested by the user in the form
    url = results.url
    url = url.sub! 'send=1', 'send=0' if args[:starting_view] == 'recipient'

    { 'envelope_id' => envelope_id, 'redirect_url' => url }
  end
end