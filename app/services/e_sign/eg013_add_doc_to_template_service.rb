# frozen_string_literal: true

class ESign::Eg013AddDocToTemplateService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  #ds-snippet-start:eSign13Step3
  def worker
    envelope_args = args[:envelope_args]
    # 1. Create the envelope request object
    envelope_definition = make_envelope(envelope_args)
    # 2. call Envelopes::create API method
    # Exceptions will be caught by the calling function
    envelope_api = create_envelope_api(args)

    results = envelope_api.create_envelope(args[:account_id], envelope_definition)
    envelope_id = results.envelope_id
    #ds-snippet-end:eSign13Step3
    # 3. Create the Recipient View request object
    #ds-snippet-start:eSign13Step4
    authentication_method = 'None' # How is this application authenticating
    # the signer? See the `authenticationMethod' definition
    # https://developers.docusign.com/docs/esign-rest-api/reference/envelopes/envelopeviews/createrecipient/
    recipient_view_request = DocuSign_eSign::RecipientViewRequest.new(
      authenticationMethod: authentication_method,
      returnUrl: envelope_args[:ds_return_url],
      userName: envelope_args[:signer_name],
      email: envelope_args[:signer_email],
      clientUserId: envelope_args[:signer_client_id]
    )
    # 4. Obtain the recipient_view_url for the embedded signing
    # Exceptions will be caught by the calling function
    results = envelope_api.create_recipient_view(args[:account_id],
                                                 envelope_id, recipient_view_request)
    { envelope_id: envelope_id, redirect_url: results.url }
  end
  #ds-snippet-end:eSign13Step4

  private

  #ds-snippet-start:eSign13Step2
  def make_envelope(args)
    # 1. Create recipients for server template. Note that the Recipients object
    #    is used, not TemplateRole
    #
    # Create a signer recipient for the signer role of the server template
    signer1 = DocuSign_eSign::Signer.new(
      email: args[:signer_email], name: args[:signer_name],
      roleName: 'signer', recipientId: '1',
      # Adding clientUserId transforms the template recipient into an embedded recipient
      clientUserId: args[:signer_client_id]
    )
    cc1 = DocuSign_eSign::CarbonCopy.new(
      email: args[:cc_email], name: args[:cc_name],
      roleName: 'cc', recipientId: '2'
    )
    # Recipients object
    recipients_server_template = DocuSign_eSign::Recipients.new(
      'carbonCopies' => [cc1], 'signers' => [signer1]
    )

    # 2. Create a composite template for the Server template + roles
    comp_template1 = DocuSign_eSign::CompositeTemplate.new(
      compositeTemplate_id: '1',
      serverTemplates: [DocuSign_eSign::ServerTemplate.new(
        sequence: '1', templateId: args[:template_id]
      )],
      # Add the roles via an inlineTemplate
      inlineTemplates: [
        DocuSign_eSign::InlineTemplate.new(
          'sequence' => '2',
          'recipients' => recipients_server_template
        )
      ]
    )

    # Next, create the second composite template that will include the new document
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
      roleName: 'signer', recipientId: '1',
      clientUserId: args[:signer_client_id],
      tabs: signer1_tabs
    )

    # 5. The Recipients object for the added document using cc1 definition from above
    recipients_added_doc = DocuSign_eSign::Recipients.new(
      carbonCopies: [cc1], signers: [signer1AddedDoc]
    )

    # 6. Create the HTML document that will be added to the envelope
    doc1_b64 = Base64.encode64(create_document1(args))
    doc1 = DocuSign_eSign::Document.new(
      documentBase64: doc1_b64,
      name: 'Appendix 1--Sales order', # Can be different from actual file name
      fileExtension: 'html', documentId: '1'
    )

    # 7. Create a composite template for the added document
    comp_template2 = DocuSign_eSign::CompositeTemplate.new(
      compositeTemplateId: '2',
      # Add the recipients via an inlineTemplate
      inlineTemplates: [
        DocuSign_eSign::InlineTemplate.new(
          sequence: '1', recipients: recipients_added_doc
        )
      ],
      document: doc1
    )
    # 8. Create the envelope definition with the composited templates
    DocuSign_eSign::EnvelopeDefinition.new(
      status: 'sent',
      compositeTemplates: [comp_template1, comp_template2]
    )
  end

  def create_document1(args)
    <<~HEREDOC
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
  #ds-snippet-end:eSign13Step2
end
