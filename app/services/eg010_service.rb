class Eg010Service
  attr_reader :args, :envelope_args, :session

  def initialize(request, session)
    @envelope_args = {
      # Validation: Delete any non-usual characters
      signer_email: request.params['signerEmail'].gsub(/([^\w \-\@\.\,])+/, ''),
      signer_name: request.params['signerName'].gsub(/([^\w \-\@\.\,])+/, ''),
      cc_email: request.params['ccEmail'].gsub(/([^\w \-\@\.\,])+/, ''),
      cc_name: request.params['ccName'].gsub(/([^\w \-\@\.\,])+/, '')
    }

    @args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      envelope_args: @envelope_args
    }

    @session = session
  end

  def call
    results = worker
    session[:envelope_id] = results['envelope_id']
    results
  end

  private

  # ***DS.snippet.0.start
  def worker
    envelope_args = args[:envelope_args]
    # Step 1. Make the envelope JSON request body
    envelopeJSON = make_envelope_json
    # Step 2. Gather documents and their headers
    # Read files from a local directory
    # The reads could raise an exception if the file is not available!
    config = Rails.application.config
    doc2_docx_bytes = File.binread(File.join('data', config.doc_docx))
    doc3_pdf_bytes = File.binread(File.join('data', config.doc_pdf))

    documents = [
      { mime: 'text/html',
        filename: envelopeJSON[:documents][0][:name],
        document_id: envelopeJSON[:documents][0][:documentId],
        # See encoding note below for explanation
        bytes: create_document1.force_encoding('ASCII-8BIT') },
      { mime: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        filename: envelopeJSON[:documents][1][:name],
        document_id: envelopeJSON[:documents][1][:documentId],
        bytes: doc2_docx_bytes },
      { mime: 'application/pdf',
        filename: envelopeJSON[:documents][2][:name],
        document_id: envelopeJSON[:documents][2][:documentId],
        bytes: doc3_pdf_bytes }
    ]

    # Step 3. Create and send the envelope
    crlf = "\r\n"
    boundary = 'multipartboundary_multipartboundary'
    hyphens = '--'

    # ENCODING NOTE
    # We're using an array to build up the buffer. The binary elements
    # (the binary PDF and Word docs) use the psuedo Ruby binary encodiing of
    # 'ASCII-8BIT'. So the buffer.join method is looking for ASCII-8BIT "strings"
    # to join together. That's a problem with the HTML document, since it
    # includes non-ASCII characters (UTF-8 accented characters).
    # To avoid the Ruby error of Encoding::CompatibilityError (incompatible character
    # encodings: UTF-8 and ASCII-8BIT) we force the interpretation of the
    # HTML UTF-8 doc as ASCII-8BIT. By using the String#force_encoding, we change the
    # encoding used to label the string, but without changing the internal byte
    # representation of the UTF-8 string.
    # See http://ruby-doc.org/core-2.1.2/Encoding.html#class-Encoding-label-Changing+an+encoding
    buffer = []
    buffer << hyphens
    buffer << boundary
    buffer << crlf
    buffer << 'Content-Type: application/json'
    buffer << crlf
    buffer << 'Content-Disposition: form-data'
    buffer << crlf
    buffer << crlf
    buffer << envelopeJSON.to_json

    documents.each do |doc|
      buffer << crlf
      buffer << hyphens
      buffer << boundary
      buffer << crlf
      buffer << "Content-Type: #{doc[:mime]}"
      buffer << crlf
      buffer << "Content-Disposition: file; filename=#{doc[:filename]};documentid=#{doc[:document_id]}"
      buffer << crlf
      buffer << crlf
      buffer << doc[:bytes]
    end

    # Add closing boundary
    buffer << crlf
    buffer << hyphens
    buffer << boundary
    buffer << hyphens
    buffer << crlf

    header = {
      "Accept": 'application/json',
      "Authorization": "Bearer #{args[:access_token]}"
    }
    # Change your API version in the URL below to v2 for API version 2
    uri = URI.parse("#{args[:base_path]}/v2.1/accounts/#{args[:account_id]}/envelopes")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    req = Net::HTTP::Post.new(uri, header)
    req.content_type = "multipart/form-data; boundary=#{boundary}"
    # req.accept = "application/json"
    req.body = buffer.join

    response = http.request(req)
    obj = JSON.parse(response.body)

    if (response.code.to_i >= 200) && (response.code.to_i < 300)
      envelope_id = obj['envelopeId']
      session[:envelope_id] = envelope_id
      { 'envelope_id' => envelope_id }
    else
      raise Net::HTTPError.new(response.code, response.body)
    end
  end


  def make_envelope_json
    # document 1 (HTML) has tag **signature_1**
    # document 2 (DOCX) has tag /sn1/
    # document 3 (PDF) has tag /sn1/
    #
    # The envelope has two recipients.
    # recipient 1 - signer
    # recipient 2 - cc
    # The envelope will be sent first to the signer
    # After it is signed, a copy is sent to the cc person

    # Create the envelope definition
    env_json = {} # DocuSign_eSign::EnvelopeDefinition.new

    puts env_json[:emailSubject] = 'Please sign this document set'

    # Add the documents
    doc1 = {}
    doc2 = {}
    doc3 = {}

    puts doc1[:name] = 'Order acknowledgement' # Can be different from actual file name
    puts doc1[:fileExtension] = 'html' # Source data format. Signed docs are always PDF
    puts doc1[:documentId] = '1' # A label used to reference the doc
    puts doc2[:name] = 'Battle Plan' # Can be different from actual file name
    puts doc2[:fileExtension] = 'docx'
    puts doc2[:documentId] = '2'
    puts doc3[:name] = 'Lorem Ipsum' # Can be different from actual file name
    puts doc3[:fileExtension] = 'pdf'
    puts doc3[:documentId] = '3'

    puts env_json[:documents] = [doc1, doc2, doc3]
    # Create a signer recipient to sign the document, identified by name and email
    # We're setting the parameters via the object creation
    signer1 = DocuSign_eSign::Signer.new
    signer1.email = envelope_args[:signer_email]
    signer1.name = envelope_args[:signer_name]
    signer1.recipient_id = '1'
    signer1.routing_order = '1'
    # routingOrder (lower means earlier) determines the order of deliveries
    # to the recipients. Parallel routing order is supported by using the
    # same integer as the order for two or more recipients

    # Create a cc recipient to receive a copy of the documents, identified by name and email
    # We're setting the parameters via setters
    cc1 = DocuSign_eSign::CarbonCopy.new(
      email: envelope_args[:cc_email],
      name: envelope_args[:cc_name],
      routingOrder: '2',
      recipientId: '2'
    )
    # Create signHere fields (also known as tabs) on the documents,
    # We're using anchor (autoPlace) positioning
    #
    # The DocuSign platform searches throughout your envelope's documents for matching
    # anchor strings. So the sign_here_2 tab will be used in both document 2 and 3
    # since they use the same anchor string for their "signer 1" tabs.
    sign_here1 = DocuSign_eSign::SignHere.new ({
      anchorString: '**signature_1**',
      anchorYOffset: '10',
      anchorUnits: 'pixels',
      anchorXOffset: '20'
    })

    sign_here2 = DocuSign_eSign::SignHere.new ({
      anchorString: '/sn1/',
      anchorYOffset: '10',
      anchorUnits: 'pixels',
      anchorXOffset: '20'
    })
    # Tabs are set per recipient/signer
    signer1_tabs = DocuSign_eSign::Tabs.new ({
      signHereTabs: [sign_here1, sign_here2]
    })

    signer1.tabs = signer1_tabs

    recipients = DocuSign_eSign::Recipients.new(
      signers: [signer1],
      carbonCopies: [cc1]
    )

    puts env_json[:recipients] = recipients
    puts env_json[:status] = 'sent'
    env_json
  end

  def create_document1
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
        <p style=\"margin-top:0em; margin-bottom:0em;\">Email: #{args[:signer_email]}</p>
        <p style=\"margin-top:0em; margin-bottom:0em;\">Copy to: #{args[:cc_name]}, #{args[:cc_email]}</p>
        <p style=\"margin-top:3em;\">
  Candy bonbon pastry jujubes lollipop wafer biscuit biscuit. Topping brownie sesame snaps sweet roll pie. Croissant danish biscuit soufflé caramels jujubes jelly. Dragée danish caramels lemon drops dragée. Gummi bears cupcake biscuit tiramisu sugar plum pastry. Dragée gummies applicake pudding liquorice. Donut jujubes oat cake jelly-o. Dessert bear claw chocolate cake gummies lollipop sugar plum ice cream gummies cheesecake.
        </p>
        <!-- Note the anchor tag for the signature field is in white. -->
        <h3 style=\"margin-top:3em;\">Agreed: <span style=\"color:white;\">**signature_1**/</span></h3>
        </body>
    </html>"
  end
  # ***DS.snippet.0.end
end