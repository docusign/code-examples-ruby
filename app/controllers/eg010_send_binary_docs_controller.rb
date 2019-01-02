require 'net/http'

class Eg010SendBinaryDocsController < EgController
  skip_before_action :verify_authenticity_token
  @title = 'Send envelope with multipart mime'
  def eg_name
    'eg010'
  end
  def get_file_name
    File.basename __FILE__
  end

  def create
    minimum_buffer_min = 3
    if check_token minimum_buffer_min
      envelope_args = {
        # Validation: Delete any non-usual characters
        signer_email: request.params['signerEmail'].gsub(/([^\w \-\@\.\,])+/, ''),
        signer_name: request.params['signerName'].gsub(/([^\w \-\@\.\,])+/, ''),
        cc_email: request.params['ccEmail'].gsub(/([^\w \-\@\.\,])+/, ''),
        cc_name: request.params['ccName'].gsub(/([^\w \-\@\.\,])+/, ''),
      }

      args = {
        account_id: session['ds_account_id'],
        base_path: session['ds_base_path'],
        access_token: session['ds_access_token'],
        envelope_args: envelope_args
      }
      begin
        results = worker args
        session[:envelope_id] = results['envelope_id']
        @title = 'Envelope sent'
        @h1 = 'Envelope sent'
        @message = "The envelope has been created and sent!<br/>Envelope ID #{results['envelope_id']}."
        render 'ds_common/example_done'
      rescue Net::HTTPError => e
        if !e.response.nil?
          json_response = JSON.parse e.response
          @error_code = json_response['errorCode']
          @error_message = json_response['message']
        else
          @error_code = 'API request problem'
          @error_message = "#{e}"
        end
      end
    else
      flash[:message] = 'Sorry, you need to re-authenticate.'
      # We could store the parameters of the requested operation
      # so it could be restarted automatically.
      # But since it should be rare to have a token issue here,
      # we'll make the user re-enter the form data after
      # authentication.
      session['eg'] = eg_name
      redirect_to '/ds/mustAuthenticate'
    end
  end

  # ***DS.snippet.0.start
  def worker(args)
    envelope_args = args[:envelope_args]
    # Step 1. Make the envelope JSON request body
    envelopeJSON = make_envelope_json(envelope_args)
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
        # See encoding note, below, for explanation
        bytes: create_document1(envelope_args).force_encoding('ASCII-8BIT') },
      { mime: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        filename: envelopeJSON[:documents][1][:name],
        document_id: envelopeJSON[:documents][1][:documentId],
        bytes: doc2_docx_bytes },
      { mime: 'application/pdf',
        filename: envelopeJSON[:documents][2][:name],
        document_id: envelopeJSON[:documents][2][:documentId],
        bytes: doc3_pdf_bytes }
    ]

    # Step 3. Create the multipart body
    crlf = "\r\n"
    boundary = 'multipartboundary_multipartboundary'
    hyphens = '--'

    # ENCODING NOTE
    # We're using an array to build up the buffer.
    # The binary elements (the binary PDF and Word docs) use the psuedo Ruby
    # binary encodiing of 'ASCII-8BIT'. So the buffer.join method is
    # looking for ASCII-8BIT "strings" to join together.
    # That's a problem with the HTML document since it includes
    # non-ASCII characters (UTF-8 accented characters).
    # To avoid the Ruby error of 
    # Encoding::CompatibilityError (incompatible character encodings: UTF-8 and ASCII-8BIT)
    # we force the interpretation of the HTML UTF-8 doc as ASCII-8BIT.
    # By using the String#force_encoding, we change the encoding the string is
    # labelled with but without changing the internal byte representation of the UTF-8 string.
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

    uri = URI.parse("#{args[:base_path]}/v2/accounts/#{args[:account_id]}/envelopes")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    req = Net::HTTP::Post.new(uri, header)
    req.content_type =  "multipart/form-data; boundary=#{boundary}"
    # req.accept = "application/json"
    req.body = buffer.join

    response = http.request(req)
    obj = JSON.parse(response.body)

    if response.code.to_i >= 200 and response.code.to_i < 300
      envelope_id = obj['envelopeId']
      session[:envelope_id] = envelope_id
      { 'envelope_id' => envelope_id }
    else
      raise Net::HTTPError.new(response.code, response.body)
    end
  end

  def create_document1(args)
    return "
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

  def make_envelope_json(envelope_args)
    # document 1 (html) has tag **signature_1**
    # document 2 (docx) has tag /sn1/
    # document 3 (pdf) has tag /sn1/
    #
    # The envelope has two recipients.
    # recipient 1 - signer
    # recipient 2 - cc
    # The envelope will be sent first to the signer.
    # After it is signed, a copy is sent to the cc person.

    # create the envelope definition
    env_json = {}#DocuSign_eSign::EnvelopeDefinition.new

    puts env_json[:emailSubject] = 'Please sign this document set'

    # add the documents
    doc1 = {}
    doc2 = {}
    doc3 = {}

    puts doc1[:name] = 'Order acknowledgement' # can be different from actual file name
    puts doc1[:fileExtension] = 'html' # Source data format. Signed docs are always pdf.
    puts doc1[:documentId] = '1' # a label used to reference the doc
    puts doc2[:name] = 'Battle Plan' # can be different from actual file name
    puts doc2[:fileExtension] = 'docx'
    puts doc2[:documentId] = '2'
    puts doc3[:name] = 'Lorem Ipsum' # can be different from actual file name
    puts doc3[:fileExtension] = 'pdf'
    puts doc3[:documentId]  = '3'

    puts env_json[:documents] = [doc1, doc2, doc3]
    # create a signer recipient to sign the document, identified by name and email
    # We're setting the parameters via the object creation
    signer1 = DocuSign_eSign::Signer.new
    signer1.email = envelope_args[:signer_email]
    signer1.name = envelope_args[:signer_name]
    signer1.recipient_id = '1'
    signer1.routing_order = '1'
    # routingOrder (lower means earlier) determines the order of deliveries
    # to the recipients. Parallel routing order is supported by using the
    # same integer as the order for two or more recipients.

    # create a cc recipient to receive a copy of the documents, identified by name and email
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
    # The DocuSign platform searches throughout your envelope's
    # documents for matching anchor strings. So the
    # signHere2 tab will be used in both document 2 and 3 since they
    # use the same anchor string for their "signer 1" tabs.
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
    # Tabs are set per recipient / signer
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
  # ***DS.snippet.0.end
end
