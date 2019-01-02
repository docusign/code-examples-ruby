class Eg013AddDocToTemplateController < EgController
  skip_before_action :verify_authenticity_token
  def eg_name
    "eg013"
  end
  def get_file_name
    File.basename __FILE__
  end

  def create
    minimum_buffer_min = 3
    template_id = session[:template_id]
    token_ok = check_token(minimum_buffer_min)

    if token_ok && template_id
      # 2. Call the worker method
      # More data validation would be a good idea here
      # Strip anything other than characters listed
      envelope_args = {
        signer_email: request.params['signerEmail'].gsub(/([^\w \-\@\.\,])+/, ''),
        signer_name: request.params['signerName'].gsub(/([^\w \-\@\.\,])+/, ''),
        cc_email: request.params['ccEmail'].gsub(/([^\w \-\@\.\,])+/, ''),
        cc_name: request.params['ccName'].gsub(/([^\w \-\@\.\,])+/, ''),
        item: request.params['item'].gsub(/([^\w \-\@\.\,])+/, ''),
        quantity: request.params['quantity'].gsub(/([^\w \-\@\.\,])+/, '').to_i,
        signer_client_id: 1000,
        template_id: template_id,
        ds_return_url: "#{Rails.application.config.app_url}/ds_common-return"
      }
      args = {
        account_id: session['ds_account_id'],
        base_path: session['ds_base_path'],
        access_token: session['ds_access_token'],
        envelope_args: envelope_args
      }

      begin
        results = worker args
        session[:envelope_id] = results[:envelope_id] # Save for use by other examples
        # which need an envelopeId
        # Redirect the user to the signing ceremony
        # Don't use an iFrame!
        # State can be stored/recovered using the framework's session or a
        # query parameter on the returnUrl
        redirect_to results[:redirect_url]
      rescue DocuSign_eSign::ApiError => e
        error = JSON.parse e.response_body
        @error_code = error['errorCode']
        @error_message = error['message']
        render "ds_common/error"
      end
    elsif !token_ok
      flash[:messages] = 'Sorry, you need to re-authenticate.'
      # We could store the parameters of the requested operation
      # so it could be restarted automatically.
      # But since it should be rare to have a token issue here,
      # we'll make the user re-enter the form data after
      # authentication.
      redirect_to '/ds/mustAuthenticate'
    elsif !template_id
      @title = "Embedded Signing Ceremony from template and extra doc",
      @template_ok = false
    end
  end

  # ***DS.snippet.0.start
  def worker(args)
    envelope_args = args[:envelope_args]
    # 1. Create the envelope request object
    envelope_definition = make_envelope(envelope_args)
    # 2. call Envelopes::create API method
    # Exceptions will be caught by the calling function
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:base_path]
    api_client = DocuSign_eSign::ApiClient.new configuration
    api_client.default_headers["Authorization"] = "Bearer " + args[:access_token]
    envelopes_api = DocuSign_eSign::EnvelopesApi.new api_client

    results = envelopes_api.create_envelope(args[:account_id], envelope_definition)
    envelope_id = results.envelope_id
    # 3. Create the Recipient View request object
    authentication_method = 'None' # How is this application authenticating
    # the signer? See the `authenticationMethod' definition
    # https://developers.docusign.com/esign-rest-api/reference/Envelopes/EnvelopeViews/createRecipient
    recipient_view_request = DocuSign_eSign::RecipientViewRequest.new(
      :authenticationMethod => authentication_method,
      :returnUrl => envelope_args[:ds_return_url],
      :userName => envelope_args[:signer_name],
      :email => envelope_args[:signer_email],
      :clientUserId => envelope_args[:signer_client_id]
      )
    # 4. Obtain the recipient_view_url for the signing ceremony
    # Exceptions will be caught by the calling function
    results = envelopes_api.create_recipient_view(args[:account_id], 
                envelope_id, recipient_view_request)
    {envelope_id: envelope_id, redirect_url: results.url}
  end

  def make_envelope(args)
    # 1. Create Recipients for server template. Note that Recipients object
    #    is used, not TemplateRole
    #
    # Create a signer recipient for the signer role of the server template
    signer1 = DocuSign_eSign::Signer.new(
      email: args[:signer_email], name: args[:signer_name],
      roleName: "signer", recipientId: "1",
      # Adding clientUserId transforms the template recipient
      # into an embedded recipient:
      clientUserId: args[:signer_client_id]
      )
    cc1 = DocuSign_eSign::CarbonCopy.new(
      email: args[:cc_email], name: args[:cc_name],
      roleName: "cc", recipientId: "2"
      )
    # Recipients object:
    recipients_server_template = DocuSign_eSign::Recipients.new(
      'carbonCopies' => [cc1], 'signers' => [signer1])

    # 2. create a composite template for the Server template + roles
    comp_template1 = DocuSign_eSign::CompositeTemplate.new(
      compositeTemplate_id: "1",
      serverTemplates: [DocuSign_eSign::ServerTemplate.new(
        sequence: "1", templateId: args[:template_id])
      ],
      # Add the roles via an inlineTemplate
      inlineTemplates: [
        DocuSign_eSign::InlineTemplate.new(
          'sequence' => "1",
          'recipients' => recipients_server_template)
      ]
    )

    # Next, create the second composite template that will
    # include the new document.
    #
    # 3. Create the signer recipient for the added document
    #    starting with the tab definition:
    sign_here1 = DocuSign_eSign::SignHere.new(
      anchorString: '**signature_1**',
      anchorYOffset: '10', anchorUnits: 'pixels',
      anchorXOffset: '20'
    )
    signer1_tabs = DocuSign_eSign::Tabs.new('signHereTabs' => [sign_here1])

    # 4. Create Signer definition for the added document
    signer1AddedDoc = DocuSign_eSign::Signer.new(
      email: args[:signer_email],
      name: args[:signer_name],
      roleName: "signer", recipientId: "1",
      clientUserId: args[:signer_client_id],
      tabs: signer1_tabs
    )

    # 5. The Recipients object for the added document.
    #    Using cc1 definition from above.
    recipients_added_doc = DocuSign_eSign::Recipients.new(
      carbonCopies: [cc1], signers: [signer1AddedDoc])

    # 6. Create the HTML document that will be added to the envelope
    doc1_b64 = Base64.encode64(create_document1(args))
    doc1 = DocuSign_eSign::Document.new(
      documentBase64: doc1_b64,
      name: 'Appendix 1--Sales order', # can be different from actual file name
      fileExtension: 'html', documentId: '1'
    )

    # 6. create a composite template for the added document
    comp_template2 = DocuSign_eSign::CompositeTemplate.new(
      compositeTemplateId: "2",
      # Add the recipients via an inlineTemplate
      inlineTemplates: [
        DocuSign_eSign::InlineTemplate.new(
          sequence: "2", recipients: recipients_added_doc)
      ],
      document: doc1
    )
    # 7. create the envelope definition with the composited templates
    envelope_definition = DocuSign_eSign::EnvelopeDefinition.new(
      status: "sent",
      compositeTemplates: [comp_template1, comp_template2]
    )

    envelope_definition
  end

  def create_document1(args)
    return <<~HEREDOC
    <!DOCTYPE html>
    <html>
        <head>
          <meta charset="UTF-8">
        </head>
        <body style="font-family:sans-serif;margin-left:2em;">
        <h1 style="font-family: 'Trebuchet MS', Helvetica, sans-serif;
color: darkblue;margin-bottom: 0;">World Wide Corp</h1>
        <h2 style="font-family: 'Trebuchet MS', Helvetica, sans-serif;
margin-top: 0px;margin-bottom: 3.5em;font-size: 1em;
color: darkblue;">Order Processing Division</h2>
        <h4>Ordered by #{args[:signer_name]}</h4>
        <p style="margin-top:0em; margin-bottom:0em;">Email: #{args[:signer_email]}</p>
        <p style="margin-top:0em; margin-bottom:0em;">Copy to: #{args[:cc_name]}, #{args[:cc_email]}</p>
        <p style="margin-top:3em; margin-bottom:0em;">Item: <b>#{args[:item]}</b>, quantity: <b>#{args[:quantity]}</b> at market price.</p>
        <p style="margin-top:3em;">
  Candy bonbon pastry jujubes lollipop wafer biscuit biscuit. Topping brownie sesame snaps sweet roll pie. Croissant danish biscuit soufflé caramels jujubes jelly. Dragée danish caramels lemon drops dragée. Gummi bears cupcake biscuit tiramisu sugar plum pastry. Dragée gummies applicake pudding liquorice. Donut jujubes oat cake jelly-o. Dessert bear claw chocolate cake gummies lollipop sugar plum ice cream gummies cheesecake.
        </p>
        <!-- Note the anchor tag for the signature field is in white. -->
        <h3 style="margin-top:3em;">Agreed: <span style="color:white;">**signature_1**/</span></h3>
        </body>
    </html>
    HEREDOC
  end
  # ***DS.snippet.0.start
end