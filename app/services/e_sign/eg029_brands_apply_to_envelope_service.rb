# frozen_string_literal: true

class ESign::Eg029BrandsApplyToEnvelopeService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    # Step 1. Obtain your OAuth token
    # Step 2. Construct your API headers
    envelope_api = create_envelope_api(args)
    # Step 3: Construct your envelope JSON body
    #ds-snippet-start:eSign29Step3
    envelope_definition = make_envelope(args[:envelope_args])
    #ds-snippet-end:eSign29Step3
    # Step 4. Call the eSignature REST API
    #ds-snippet-start:eSign29Step4
    envelope_api.create_envelope args[:account_id], envelope_definition
    #ds-snippet-end:eSign29Step4
  end

  private

  #ds-snippet-start:eSign29Step3
  def make_envelope(envelope_args)
    envelope_definition = DocuSign_eSign::EnvelopeDefinition.new
    envelope_definition.email_blurb = 'Sample text for email body'
    envelope_definition.email_subject = 'Please Sign'
    envelope_definition.envelope_id_stamping = true
    envelope_definition.brand_id = envelope_args[:brands]

    # Add the documents and create the document models
    pdf_filename = 'World_Wide_Corp_lorem.pdf'
    document1 = DocuSign_eSign::Document.new(
      # Create the DocuSign Document object
      documentBase64: Base64.encode64(File.binread(File.join('data', pdf_filename))),
      name: 'NDA', # Can be different from actual file name
      fileExtension: 'pdf', # Many different document types are accepted
      documentId: '1' # A label used to reference the doc
    )

    envelope_definition.documents = [document1]

    # Create the signer recipient model
    signer1 = DocuSign_eSign::Signer.new
    signer1.name = envelope_args[:signer_name]
    signer1.email = envelope_args[:signer_email]
    signer1.role_name = 'signer'
    signer1.note = ''
    signer1.routing_order = '1'
    signer1.status = envelope_args[:status]
    signer1.delivery_method = 'email'
    signer1.recipient_id = '1'

    sign_here1 = DocuSign_eSign::SignHere.new
    sign_here1.document_id = '1'
    sign_here1.name = 'SignHereTab'
    sign_here1.page_number = '1'
    sign_here1.recipient_id = '1'
    sign_here1.tab_label = 'SignHereTab'
    sign_here1.x_position = '75'
    sign_here1.y_position = '572'

    # Add the tabs model (including the sign_here tabs) to the signer
    # The Tabs object wants arrays of the different field/tab types
    signer1_tabs = DocuSign_eSign::Tabs.new({
                                              signHereTabs: [sign_here1]
                                            })
    signer1.tabs = signer1_tabs

    # Add the recipients to the envelope object
    recipients = DocuSign_eSign::Recipients.new(
      signers: [signer1]
    )

    # Request that the envelope be sent by setting status to 'sent'
    # To request that the envelope be created as a draft, set status to 'created'
    envelope_definition.recipients = recipients
    envelope_definition.status = envelope_args[:status]
    envelope_definition
  end
  #ds-snippet-end:eSign29Step3
end
