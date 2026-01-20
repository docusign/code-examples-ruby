# frozen_string_literal: true

class ESign::Eg037SmsDeliveryService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    # Create the envelope request object
    envelope_definition = make_envelope(args[:envelope_args])

    # Create and send the envelope
    # Call Envelopes::create API method
    # Exceptions will be caught by the calling function
    envelope_api = create_envelope_api(args)
    #ds-snippet-start:eSign37Step3
    results, _status, headers = envelope_api.create_envelope_with_http_info args[:account_id], envelope_definition

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:eSign37Step3
    envelope_id = results.envelope_id
    { 'envelope_id' => envelope_id }
  end

  private

  #ds-snippet-start:eSign37Step2
  def make_envelope(envelope_args)
    # document 1 (HTML) has tag **signature_1**
    # document 2 (DOCX) has tag /sn1/
    # document 3 (PDF) has tag /sn1/
    #
    # The envelope has two recipients:
    # recipient 1 - signer
    # recipient 2 - cc
    # The envelope will be sent first to the signer via SMS
    # After it is signed, a copy is sent to the cc person via SMS

    # Create the envelope definition
    envelope_definition = DocuSign_eSign::EnvelopeDefinition.new

    envelope_definition.email_subject = 'Please sign this document set'

    # Add the documents
    doc1_b64 = Base64.encode64(create_document1(envelope_args))
    # Read files 2 and 3 from a local directory
    # The reads could raise an exception if the file is not available!
    doc_docx = Rails.application.config.doc_docx
    doc2_b64 = Base64.encode64(File.binread(File.join('data', doc_docx)))
    doc_pdf = Rails.application.config.doc_pdf
    doc3_b64 = Base64.encode64(File.binread(File.join('data', doc_pdf)))

    # Create the document models
    document1 = DocuSign_eSign::Document.new(
      # Create the Docusign document object
      documentBase64: doc1_b64,
      name: 'Order acknowledgement', # Can be different from actual file name
      fileExtension: 'html', # Many different document types are accepted
      documentId: '1' # A label used to reference the doc
    )
    document2 = DocuSign_eSign::Document.new(
      # Create the Docusign document object
      documentBase64: doc2_b64,
      name: 'Battle Plan', # Can be different from actual file name
      fileExtension: 'docx', # Many different document types are accepted
      documentId: '2' # A label used to reference the do
    )
    document3 = DocuSign_eSign::Document.new(
      # Create the Docusign document object
      documentBase64: doc3_b64,
      name: 'Lorem Ipsum', # Can be different from actual file name
      fileExtension: 'pdf', # Many different document types are accepted
      documentId: '3' # A label used to reference the doc
    )

    # The order in the docs array determines the order in the envelope
    envelope_definition.documents = [document1, document2, document3]

    signer_phone_number = DocuSign_eSign::RecipientPhoneNumber.new
    signer_phone_number.country_code = envelope_args[:country_code]
    signer_phone_number.number = envelope_args[:phone_number]

    # Create the signer recipient model
    signer1 = DocuSign_eSign::Signer.new
    signer1.phone_number = signer_phone_number
    signer1.name = envelope_args[:signer_name]
    signer1.recipient_id = '1'
    signer1.routing_order = '1'
    signer1.delivery_method = envelope_args[:delivery_method]

    ## routingOrder (lower means earlier) determines the order of deliveries
    # to the recipients. Parallel routing order is supported by using the
    # same integer as the order for two or more recipients

    cc_phone_number = DocuSign_eSign::RecipientPhoneNumber.new
    cc_phone_number.country_code = envelope_args[:cc_country_code]
    cc_phone_number.number = envelope_args[:cc_phone_number]

    # Create a cc recipient to receive a copy of the documents
    cc1 = DocuSign_eSign::CarbonCopy.new
    cc1.name = envelope_args[:cc_name]
    cc1.routing_order = '2'
    cc1.recipient_id = '2'
    cc1.phone_number = cc_phone_number
    cc1.delivery_method = envelope_args[:delivery_method]

    # Create signHere fields (also known as tabs) on the documents
    # We're using anchor (autoPlace) positioning
    #
    # The Docusign platform searches throughout your envelope's documents for matching
    # anchor strings. So the sign_here_2 tab will be used in both document 2 and 3
    # since they use the same anchor string for their "signer 1" tabs.
    sign_here1 = DocuSign_eSign::SignHere.new(
      anchorString: '**signature_1**',
      anchorYOffset: '10',
      anchorUnits: 'pixels',
      anchorXOffset: '20'
    )

    sign_here2 = DocuSign_eSign::SignHere.new(
      anchorString: '/sn1/',
      anchorYOffset: '10',
      anchorUnits: 'pixels',
      anchorXOffset: '20'
    )
    # Add the tabs model (including the sign_here tabs) to the signer
    # The Tabs object takes arrays of the different field/tab types
    signer1_tabs = DocuSign_eSign::Tabs.new({
                                              signHereTabs: [sign_here1, sign_here2]
                                            })

    signer1.tabs = signer1_tabs

    # Add the recipients to the envelope object
    recipients = DocuSign_eSign::Recipients.new(
      signers: [signer1],
      carbonCopies: [cc1]
    )
    # Request that the envelope be sent by setting status to "sent".
    # To request that the envelope be created as a draft, set status to "created"
    envelope_definition.recipients = recipients
    envelope_definition.status = envelope_args[:status]
    envelope_definition
  end

  def create_document1(args)
    "
    <!DOCTYPE html>
    <html>
        <head>
          <meta charset=\"UTF-8\">
        </head>
        <body style=\"font-family:sans-serif;margin-left:2em;\">
        <h1 style=\"font-family: 'Trebuchet MS', Helvetica, sans-serif;
color: darkblue;margin-bottom: 0;\">World Wide Corp</h1>
        <h2 style=\"font-family: 'Trebuchet MS', Helvetica, sans-serif;
margin-top: 0px;margin-bottom: 3.5em;font-size: 1em;
color: darkblue;\">Order Processing Division</h2>
        <h4>Ordered by #{args[:signer_name]}</h4>
        <p style=\"margin-top:0em; margin-bottom:0em;\">Phone number: #{args[:phone_number]}</p>
        <p style=\"margin-top:0em; margin-bottom:0em;\">Copy to: #{args[:cc_name]}, #{args[:cc_phone_number]}</p>
        <p style=\"margin-top:3em;\">
  Candy bonbon pastry jujubes lollipop wafer biscuit biscuit. Topping brownie sesame snaps sweet roll pie. Croissant danish biscuit soufflé caramels jujubes jelly. Dragée danish caramels lemon drops dragée. Gummi bears cupcake biscuit tiramisu sugar plum pastry. Dragée gummies applicake pudding liquorice. Donut jujubes oat cake jelly-o. Dessert bear claw chocolate cake gummies lollipop sugar plum ice cream gummies cheesecake.
        </p>
        <!-- Note the anchor tag for the signature field is in white. -->
        <h3 style=\"margin-top:3em;\">Agreed: <span style=\"color:white;\">**signature_1**/</span></h3>
        </body>
    </html>"
  end
  #ds-snippet-end:eSign37Step2
end
