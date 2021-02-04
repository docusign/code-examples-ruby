# frozen_string_literal: true

class ESign::Eg001EmbeddedSigningService
  include ApiCreator
  attr_reader :signer_email, :signer_name, :args

  def initialize(session, request)
    @signer_email = request.params[:signerEmail].gsub(/([^\w \-\@\.\,])+/, '')
    @signer_name =  request.params[:signerName].gsub(/([^\w \-\@\.\,])+/, '')
    @args = {
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token]
    }
  end

  def call
    redirect_url = worker
  end

  private

  # ***DS.snippet.0.start
  def worker
    ds_ping_url = Rails.application.config.app_url
    ds_return_url = "#{ds_ping_url}/ds_common-return"
    signer_client_id = 1000
    pdf_filename = 'World_Wide_Corp_lorem.pdf'

    # Step 1. Create the envelope definition
    envelope = make_envelope(signer_client_id, pdf_filename)

    # Step 2. Call DocuSign to create the envelope
    envelope_api = create_envelope_api(args)

    results = envelope_api.create_envelope args[:account_id], envelope
    envelope_id = results.envelope_id
    # Save for future use within the example launcher
    # session[:envelope_id] = envelope_id

    # Step 3. Create the recipient view for the embedded signing
    view_request = make_recipient_view_request(signer_client_id, ds_return_url, ds_ping_url
    )

    # Call the CreateRecipientView API
    results = envelope_api.create_recipient_view args[:account_id], envelope_id, view_request

    # Step 4. Redirect the user to the embedded signing
    # Don't use an iframe!
    # State can be stored/recovered using the framework's session or a
    # query parameter on the returnUrl (see the makeRecipientViewRequest method)
    # Redirect to results.url
    results.url
  end

  def make_recipient_view_request(signer_client_id, ds_return_url, ds_ping_url)
    view_request = DocuSign_eSign::RecipientViewRequest.new
    # Set the URL where you want the recipient to go once they are done signing
    # should typically be a callback route somewhere in your app.
    # The query parameter is included as an example of how
    # to save/recover state information during the redirect to
    # the DocuSign signing. It's usually better to use
    # the session mechanism of your web framework. Query parameters
    # can be changed/spoofed very easily.
    view_request.return_url = ds_return_url + '?state=123'

    # How has your app authenticated the user? In addition to your app's
    # authentication, you can include authenticate steps from DocuSign; 
    # e.g., SMS authentication
    view_request.authentication_method = 'none'

    # Recipient information must match the embedded recipient info
    # that was used to create the envelope
    view_request.email = signer_email
    view_request.user_name = signer_name
    view_request.client_user_id = signer_client_id

    # DocuSign recommends that you redirect to DocuSign for the embedded signing. There are
    # multiple ways to save state. To maintain your application's session, use the pingUrl
    # parameter. It causes the DocuSign signing web page (not the DocuSign server)
    # to send pings via AJAX to your app
    view_request.ping_frequency = '600' # seconds
    # NOTE: The pings will only be sent if the pingUrl is an HTTPS address
    view_request.ping_url = ds_ping_url # Optional setting

    view_request
  end

  def make_envelope(signer_client_id, pdf_filename)
    envelope_definition = DocuSign_eSign::EnvelopeDefinition.new
    envelope_definition.email_subject = 'Please sign this document sent from Ruby SDK'

    doc1 = DocuSign_eSign::Document.new
    doc1.document_base64 = Base64.encode64(File.binread(File.join('data', pdf_filename)))
    doc1.name = 'Lorem Ipsum'
    doc1.file_extension = 'pdf'
    doc1.document_id = '1'

    # The order in the docs array determines the order in the envelope
    envelope_definition.documents = [doc1]
    # Create a signer recipient to sign the document, identified by name and email
    # We're setting the parameters via the object creation
    signer1 = DocuSign_eSign::Signer.new ({
      email: signer_email, name: signer_name,
      clientUserId: signer_client_id, recipientId: 1
    })
    # The DocuSign platform searches throughout your envelope's documents for matching
    # anchor strings. So the sign_here_2 tab will be used in both document 2 and 3
    # since they use the same anchor string for their "signer 1" tabs.
    sign_here = DocuSign_eSign::SignHere.new
    sign_here.anchor_string = '/sn1/'
    sign_here.anchor_units = 'pixels'
    sign_here.anchor_x_offset = '20'
    sign_here.anchor_y_offset = '10'
    # Tabs are set per recipient/signer
    tabs = DocuSign_eSign::Tabs.new
    tabs.sign_here_tabs = [sign_here]
    signer1.tabs = tabs
    # Add the recipients to the envelope object
    recipients = DocuSign_eSign::Recipients.new
    recipients.signers = [signer1]

    envelope_definition.recipients = recipients
    # Request that the envelope be sent by setting status to "sent".
    # To request that the envelope be created as a draft, set status to "created"
    envelope_definition.status = 'sent'
    envelope_definition
  end
  # ***DS.snippet.0.end
end