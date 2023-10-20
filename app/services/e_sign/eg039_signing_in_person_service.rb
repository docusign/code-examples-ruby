# frozen_string_literal: true

class ESign::Eg039SigningInPersonService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    ds_ping_url = args[:ds_ping_url]
    ds_return_url = "#{ds_ping_url}/ds_common-return"
    pdf_filename = args[:pdf_filename]
    host_email = args[:host_email]
    host_name = args[:host_name]
    signer_name = args[:signer_name]

    envelope = make_envelope(pdf_filename, host_email, host_name, signer_name)

    #ds-snippet-start:eSign39Step3
    envelope_api = create_envelope_api(args)

    results = envelope_api.create_envelope args[:account_id], envelope
    #ds-snippet-end:eSign39Step3

    envelope_id = results.envelope_id

    #ds-snippet-start:eSign39Step5
    view_request = make_recipient_view_request(ds_return_url, ds_ping_url, host_email, host_name)

    # Call the CreateRecipientView API
    results = envelope_api.create_recipient_view args[:account_id], envelope_id, view_request
    #ds-snippet-end:eSign39Step5

    # Redirect the user to the embedded signing
    # Don't use an iframe!
    # State can be stored/recovered using the framework's session or a
    # query parameter on the returnUrl (see the makeRecipientViewRequest method)
    # Redirect to results.url
    results.url
  end

  private

  #ds-snippet-start:eSign39Step4
  def make_recipient_view_request(ds_return_url, ds_ping_url, host_email, host_name)
    view_request = DocuSign_eSign::RecipientViewRequest.new
    # Set the URL where you want the recipient to go once they are done signing
    # should typically be a callback route somewhere in your app.
    # The query parameter is included as an example of how
    # to save/recover state information during the redirect to
    # the DocuSign signing. It's usually better to use
    # the session mechanism of your web framework. Query parameters
    # can be changed/spoofed very easily.
    view_request.return_url = "#{ds_return_url}?state=123"

    # How has your app authenticated the user? In addition to your app's
    # authentication, you can include authenticate steps from DocuSign;
    # e.g., SMS authentication
    view_request.authentication_method = 'none'

    # Recipient information must match the embedded recipient info
    # that was used to create the envelope
    view_request.email = host_email
    view_request.user_name = host_name

    # DocuSign recommends that you redirect to DocuSign for the embedded signing. There are
    # multiple ways to save state. To maintain your application's session, use the pingUrl
    # parameter. It causes the DocuSign signing web page (not the DocuSign server)
    # to send pings via AJAX to your app
    view_request.ping_frequency = '600' # seconds
    # NOTE: The pings will only be sent if the pingUrl is an HTTPS address
    view_request.ping_url = ds_ping_url # Optional setting

    view_request
  end
  #ds-snippet-end:eSign39Step4

  #ds-snippet-start:eSign39Step2
  def make_envelope(pdf_filename, host_email, host_name, signer_name)
    envelope_definition = DocuSign_eSign::EnvelopeDefinition.new
    envelope_definition.email_subject = 'Please sign this document sent from Ruby SDK'

    doc1 = DocuSign_eSign::Document.new
    doc1.document_base64 = Base64.encode64(File.binread(pdf_filename))
    doc1.name = 'Lorem Ipsum'
    doc1.file_extension = 'pdf'
    doc1.document_id = '1'

    # The order in the docs array determines the order in the envelope
    envelope_definition.documents = [doc1]
    # Create an in person signer recipient to sign the document
    # We're setting the parameters via the object creation

    in_person_signer = DocuSign_eSign::InPersonSigner.new
    in_person_signer.host_email = host_email
    in_person_signer.host_name = host_name
    in_person_signer.signer_name = signer_name
    in_person_signer.recipient_id = '1'
    in_person_signer.routing_order = '1'

    # The DocuSign platform searches throughout your envelope's documents for matching
    # anchor strings.
    sign_here = DocuSign_eSign::SignHere.new
    sign_here.anchor_string = '/sn1/'
    sign_here.anchor_units = 'pixels'
    sign_here.anchor_x_offset = '20'
    sign_here.anchor_y_offset = '10'
    # Tabs are set per recipient/signer
    tabs = DocuSign_eSign::Tabs.new
    tabs.sign_here_tabs = [sign_here]
    in_person_signer.tabs = tabs
    # Add the recipients to the envelope object
    recipients = DocuSign_eSign::Recipients.new
    recipients.in_person_signers = [in_person_signer]

    envelope_definition.recipients = recipients
    # Request that the envelope be sent by setting status to "sent".
    # To request that the envelope be created as a draft, set status to "created"
    envelope_definition.status = 'sent'
    envelope_definition
  end
  #ds-snippet-end:eSign39Step2
end
