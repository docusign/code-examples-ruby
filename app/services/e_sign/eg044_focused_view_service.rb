# frozen_string_literal: true

class ESign::Eg044FocusedViewService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    ds_ping_url = args[:ds_ping_url]
    ds_return_url = "#{ds_ping_url}/ds_common-return"
    signer_client_id = args[:signer_client_id]
    pdf_filename = args[:pdf_filename]
    signer_email = args[:signer_email]
    signer_name = args[:signer_name]

    # Create the envelope definition
    #ds-snippet-start:eSign44Step3
    envelope = make_envelope(args[:signer_client_id], pdf_filename, signer_email, signer_name)

    # Call Docusign to create the envelope
    envelope_api = create_envelope_api(args)

    results, _status, headers = envelope_api.create_envelope_with_http_info args[:account_id], envelope

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end

    envelope_id = results.envelope_id
    #ds-snippet-end:eSign44Step3
    # Save for future use within the example launcher
    # session[:envelope_id] = envelope_id

    # Create the recipient view for the embedded signing
    #ds-snippet-start:eSign44Step5
    view_request = make_recipient_view_request(signer_client_id, ds_return_url, ds_ping_url, signer_email, signer_name)

    # Call the CreateRecipientView API
    results, _status, headers = envelope_api.create_recipient_view_with_http_info args[:account_id], envelope_id, view_request

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end

    # Redirect the user to the embedded signing
    # Don't use an iframe!
    # State can be stored/recovered using the framework's session or a
    # query parameter on the returnUrl (see the makeRecipientViewRequest method)
    # Redirect to results.url
    results.url
    #ds-snippet-end:eSign44Step5
  end

  private

  #ds-snippet-start:eSign44Step4
  def make_recipient_view_request(signer_client_id, ds_return_url, ds_ping_url, signer_email, signer_name)
    view_request = DocuSign_eSign::RecipientViewRequest.new
    # Set the URL where you want the recipient to go once they are done signing
    # should typically be a callback route somewhere in your app.
    # The query parameter is included as an example of how
    # to save/recover state information during the redirect to
    # the Docusign signing. It's usually better to use
    # the session mechanism of your web framework. Query parameters
    # can be changed/spoofed very easily.
    view_request.return_url = "#{ds_return_url}?state=123"

    # How has your app authenticated the user? In addition to your app's
    # authentication, you can include authenticate steps from Docusign;
    # e.g., SMS authentication
    view_request.authentication_method = 'none'

    # Recipient information must match the embedded recipient info
    # that was used to create the envelope
    view_request.email = signer_email
    view_request.user_name = signer_name
    view_request.client_user_id = signer_client_id

    # Docusign recommends that you redirect to Docusign for the embedded signing. There are
    # multiple ways to save state. To maintain your application's session, use the pingUrl
    # parameter. It causes the Docusign signing web page (not the Docusign server)
    # to send pings via AJAX to your app
    view_request.ping_frequency = '600' # seconds
    # NOTE: The pings will only be sent if the pingUrl is an HTTPS address
    view_request.ping_url = ds_ping_url # Optional setting

    view_request.frame_ancestors = ['http://localhost:3000', 'https://apps-d.docusign.com']
    view_request.message_origins = ['https://apps-d.docusign.com']

    view_request
  end
  #ds-snippet-end:eSign44Step4

  #ds-snippet-start:eSign44Step2
  def make_envelope(signer_client_id, pdf_filename, signer_email, signer_name)
    envelope_definition = DocuSign_eSign::EnvelopeDefinition.new
    envelope_definition.email_subject = 'Please sign this document sent from Ruby SDK'

    doc1 = DocuSign_eSign::Document.new
    doc1.document_base64 = Base64.encode64(File.binread(pdf_filename))
    doc1.name = 'Lorem Ipsum'
    doc1.file_extension = 'pdf'
    doc1.document_id = '1'

    # The order in the docs array determines the order in the envelope
    envelope_definition.documents = [doc1]
    # Create a signer recipient to sign the document, identified by name and email
    # We're setting the parameters via the object creation
    signer1 = DocuSign_eSign::Signer.new({
                                           email: signer_email, name: signer_name,
                                           clientUserId: signer_client_id, recipientId: 1
                                         })
    # The Docusign platform searches throughout your envelope's documents for matching
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
  #ds-snippet-end:eSign44Step2
end
