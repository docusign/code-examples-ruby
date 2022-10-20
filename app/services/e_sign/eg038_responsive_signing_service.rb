# frozen_string_literal: true

class ESign::Eg038ResponsiveSigningService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  # Step 3 start
  def worker
    ds_return_url = "#{args[:ds_ping_url]}/ds_common-return"

    # Create the envelope definition
    envelope = make_envelope(args)

    # Call DocuSign to create the envelope
    envelope_api = create_envelope_api(args)

    results = envelope_api.create_envelope args[:account_id], envelope
    envelope_id = results.envelope_id
    # Save for future use within the example launcher
    # session[:envelope_id] = envelope_id

    # Create the recipient view for the embedded signing
    view_request = make_recipient_view_request(args, ds_return_url)

    # Call the CreateRecipientView API
    results = envelope_api.create_recipient_view args[:account_id], envelope_id, view_request

    # Step 4. Redirect the user to the embedded signing
    # Don't use an iframe!
    # State can be stored/recovered using the framework's session or a
    # query parameter on the returnUrl (see the makeRecipientViewRequest method)
    # Redirect to results.url
    results.url
  end

  private

  def make_recipient_view_request(args, ds_return_url)
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
    view_request.email = args[:signer_email]
    view_request.user_name = args[:signer_name]
    view_request.client_user_id = args[:signer_client_id]

    # DocuSign recommends that you redirect to DocuSign for the embedded signing. There are
    # multiple ways to save state. To maintain your application's session, use the pingUrl
    # parameter. It causes the DocuSign signing web page (not the DocuSign server)
    # to send pings via AJAX to your app
    view_request.ping_frequency = '600' # seconds
    # NOTE: The pings will only be sent if the pingUrl is an HTTPS address
    view_request.ping_url = args[:ds_ping_url] # Optional setting

    view_request
  end
  # Step 3 end

  # Step 2 start
  def make_envelope(args)
    envelope_definition = DocuSign_eSign::EnvelopeDefinition.new
    envelope_definition.email_subject = 'Example Signing Document'

    html_definition = DocuSign_eSign::DocumentHtmlDefinition.new
    html_definition.source = get_html_content(args)

    doc = DocuSign_eSign::Document.new
    doc.name = 'doc1.html'
    doc.document_id = '1'
    doc.html_definition = html_definition

    # The order in the docs array determines the order in the envelope
    envelope_definition.documents = [doc]
    # Create a signer recipient to sign the document, identified by name and email
    # We're setting the parameters via the object creation
    signer = DocuSign_eSign::Signer.new({
                                          email: args[:signer_email],
                                          name: args[:signer_name],
                                          clientUserId: args[:signer_client_id],
                                          recipientId: 1,
                                          role_name: 'Signer'
                                        })

    cc = DocuSign_eSign::CarbonCopy.new({
                                          email: args[:cc_email], name: args[:cc_name], recipientId: 2
                                        })

    # Add the recipients to the envelope object
    recipients = DocuSign_eSign::Recipients.new
    recipients.signers = [signer]
    recipients.carbon_copies = [cc]

    envelope_definition.recipients = recipients
    # Request that the envelope be sent by setting status to "sent".
    # To request that the envelope be created as a draft, set status to "created"
    envelope_definition.status = 'sent'
    envelope_definition
  end

  def get_html_content(args)
    doc_html = File.open(args[:doc_file]).read
    # Substitute values into the HTML
    # Substitute for: {signerName}, {signerEmail}, {ccName}, {ccEmail}
    doc_html.gsub('{signerName}', args[:signer_name]) \
            .gsub('{signerEmail}', args[:signer_email]) \
            .gsub('{ccName}', args[:cc_name]) \
            .gsub('{ccEmail}', args[:cc_email]) \
            .gsub('/sn1/', '<ds-signature data-ds-role="Signer"/>') \
            .gsub('/l1q/', '<input data-ds-type="number"/>') \
            .gsub('/l2q/', '<input data-ds-type="number"/>')
  end
  # Step 2 end
end
