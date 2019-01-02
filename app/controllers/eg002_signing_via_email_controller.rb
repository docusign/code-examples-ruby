class Eg002SigningViaEmailController < EgController
  skip_before_action :verify_authenticity_token
  def eg_name
    'eg002'
  end
  def get_file_name
    File.basename __FILE__
  end

  def create
    minimum_buffer_min = 3
    if check_token(minimum_buffer_min)
      # Call the worker method
      # More data validation would be a good idea here
      # Validation: Delete any non-usual characters
      signer_name  = request.params['signerName'].gsub(/([^\w \-\@\.\,])+/, '')
      signer_email = request.params['signerEmail'].gsub(/([^\w \-\@\.\,])+/, '')
      cc_name      = request.params['ccName'].gsub(/([^\w \-\@\.\,])+/, '')
      cc_email     = request.params['ccEmail'].gsub(/([^\w \-\@\.\,])+/, '')
      envelope_args = {
        signer_email: signer_email,
        signer_name: signer_name,
        cc_email: cc_email,
        cc_name: cc_name,
        status: 'sent'
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
        @message = "The envelope has been created and sent!<br/>Envelope ID #{results["envelope_id"]}."
        render 'ds_common/example_done'
      rescue DocuSign_eSign::ApiError => e
        error = JSON.parse e.response_body
        @error_code = error['errorCode']
        @error_message = error['message']
        render 'ds_common/error'
      end
    else
      flash[:messages] = 'Sorry, you need to re-authenticate.'
      # We could store the parameters of the requested operation
      # so it could be restarted automatically.
      # But since it should be rare to have a token issue here,
      # we'll make the user re-enter the form data after
      # authentication.
      redirect_to '/'
    end
  end

  # ***DS.snippet.0.start
  def worker (args)
    envelope_args = args[:envelope_args]
    # 1. Create the envelope request object
    envelope_definition = make_envelope(envelope_args)
    # 2. call Envelopes::create API method
    # Exceptions will be caught by the calling function
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:base_path]
    api_client = DocuSign_eSign::ApiClient.new configuration
    api_client.default_headers['Authorization'] = "Bearer #{args[:access_token]}"
    envelope_api = DocuSign_eSign::EnvelopesApi.new api_client

    results = envelope_api.create_envelope args[:account_id], envelope_definition
    envelope_id = results.envelope_id
    { 'envelope_id' => envelope_id }
  end

  # @param [Object] envelope_args
  # @return [Object]
  def make_envelope(envelope_args)
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
    envelope_definition = DocuSign_eSign::EnvelopeDefinition.new

    envelope_definition.email_subject = 'Please sign this document set'

    # add the documents
    doc1_b64 = Base64.encode64(create_document1(envelope_args))
    # read files 2 and 3 from a local directory
    # The reads could raise an exception if the file is not available!
    doc_docx = Rails.application.config.doc_docx
    doc2_b64 = Base64.encode64(File.binread(File.join('data', doc_docx)))
    doc_pdf = Rails.application.config.doc_pdf
    doc3_b64 = Base64.encode64(File.binread(File.join('data', doc_pdf)))

    # Create the document models
    document1 = DocuSign_eSign::Document.new(
      # create the DocuSign document object
      documentBase64: doc1_b64,
      name: 'Order acknowledgement',  # can be different from actual file name
      fileExtension: 'html',  # many different document types are accepted
      documentId: '1'  # a label used to reference the doc
    )
    document2 = DocuSign_eSign::Document.new(
      # create the DocuSign document object
      documentBase64: doc2_b64,
      name: 'Battle Plan',  # can be different from actual file name
      fileExtension: 'docx',  # many different document types are accepted
      documentId: '2'  # a label used to reference the do
    )
    document3 = DocuSign_eSign::Document.new(
      # create the DocuSign document object
      documentBase64: doc3_b64,
      name: 'Lorem Ipsum',  # can be different from actual file name
      fileExtension: 'pdf',  # many different document types are accepted
      documentId: '3'  # a label used to reference the doc
    )

    # The order in the docs array determines the order in the envelope
    envelope_definition.documents = [document1, document2, document3]

    # Create the signer recipient model
    signer1 = DocuSign_eSign::Signer.new
    signer1.email = envelope_args[:signer_email]
    signer1.name = envelope_args[:signer_name]
    signer1.recipient_id = '1'
    signer1.routing_order = '1'
    ## routingOrder (lower means earlier) determines the order of deliveries
    # to the recipients. Parallel routing order is supported by using the
    # same integer as the order for two or more recipients.

    # create a cc recipient to receive a copy of the documents
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
    #  use the same anchor string for their "signer 1" tabs.
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
    # The Tabs object wants arrays of the different field/tab types
    signer1_tabs = DocuSign_eSign::Tabs.new ({
      signHereTabs: [sign_here1, sign_here2]
    })

    signer1.tabs = signer1_tabs

    # Add the recipients to the envelope object
    recipients = DocuSign_eSign::Recipients.new(
      signers: [signer1],
      carbonCopies: [cc1]
    )
    # Request that the envelope be sent by setting |status| to "sent".
    # To request that the envelope be created as a draft, set to "created"
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
