# frozen_string_literal: true

class ESign::Eg038ResponsiveSigningService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  #ds-snippet-start:eSign38Step3
  def worker
    ds_return_url = "#{args[:ds_ping_url]}/ds_common-return"

    # Create the envelope definition
    envelope = make_envelope(args)

    # Call Docusign to create the envelope
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
    view_request.email = args[:signer_email]
    view_request.user_name = args[:signer_name]
    view_request.client_user_id = args[:signer_client_id]

    # Docusign recommends that you redirect to Docusign for the embedded signing. There are
    # multiple ways to save state. To maintain your application's session, use the pingUrl
    # parameter. It causes the Docusign signing web page (not the Docusign server)
    # to send pings via AJAX to your app
    view_request.ping_frequency = '600' # seconds
    # NOTE: The pings will only be sent if the pingUrl is an HTTPS address
    view_request.ping_url = args[:ds_ping_url] # Optional setting

    view_request
  end
  #ds-snippet-end:eSign38Step3

  #ds-snippet-start:eSign38Step2
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
    price_1 = 5
    formula_tab_1 = DocuSign_eSign::FormulaTab.new({
                                                     font: 'helvetica',
                                                     fontSize: 'size11',
                                                     fontColor: 'black',
                                                     anchorString: '/l1e/',
                                                     anchorYOffset: '-8',
                                                     anchorUnits: 'pixels',
                                                     anchorXOffset: '105',
                                                     tabLabel: 'l1e',
                                                     formula: "[l1q] * #{price_1}",
                                                     roundDecimalPlaces: '0',
                                                     required: 'true',
                                                     locked: 'true',
                                                     disableAutoSize: 'false'
                                                   })

    price_2 = 150
    formula_tab_2 = DocuSign_eSign::FormulaTab.new({
                                                     font: 'helvetica',
                                                     fontSize: 'size11',
                                                     fontColor: 'black',
                                                     anchorString: '/l2e/',
                                                     anchorYOffset: '-8',
                                                     anchorUnits: 'pixels',
                                                     anchorXOffset: '105',
                                                     tabLabel: 'l2e',
                                                     formula: "[l2q] * #{price_2}",
                                                     roundDecimalPlaces: '0',
                                                     required: 'true',
                                                     locked: 'true',
                                                     disableAutoSize: 'false'
                                                   })

    formula_tab_3 = DocuSign_eSign::FormulaTab.new({
                                                     font: 'helvetica',
                                                     fontSize: 'size11',
                                                     fontColor: 'black',
                                                     anchorString: '/l3t/',
                                                     anchorYOffset: '-8',
                                                     anchorUnits: 'pixels',
                                                     anchorXOffset: '105',
                                                     tabLabel: 'l3t',
                                                     formula: '[l1e] + [l2e]',
                                                     roundDecimalPlaces: '0',
                                                     required: 'true',
                                                     locked: 'true',
                                                     disableAutoSize: 'false'
                                                   })

    tabs = DocuSign_eSign::Tabs.new({
                                      formulaTabs: [formula_tab_1, formula_tab_2, formula_tab_3]
                                    })

    signer = DocuSign_eSign::Signer.new({
                                          email: args[:signer_email],
                                          name: args[:signer_name],
                                          clientUserId: args[:signer_client_id],
                                          recipientId: 1,
                                          role_name: 'Signer',
                                          tabs: tabs
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
            .gsub('/l1q/', '<input data-ds-type="number" name="l1q"/>') \
            .gsub('/l2q/', '<input data-ds-type="number" name="l2q"/>')
  end
  #ds-snippet-end:eSign38Step2
end
