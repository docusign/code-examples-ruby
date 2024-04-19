# frozen_string_literal: true

class ESign::Eg019AccessCodeAuthenticationService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    envelope_api = create_envelope_api(args)
    envelope_args = args[:envelope_args]

    #ds-snippet-start:eSign19Step3
    envelope_definition = DocuSign_eSign::EnvelopeDefinition.new
    envelope_definition.email_subject = 'Please sign this document set'

    # Add the documents and create the document models
    pdf_filename = 'World_Wide_Corp_lorem.pdf'
    document1 = DocuSign_eSign::Document.new(
      # Create the Docusign Document object
      documentBase64: Base64.encode64(File.binread(File.join('data', pdf_filename))),
      name: 'NDA', # Can be different from actual file name
      fileExtension: 'pdf', # Many different document types are accepted
      documentId: '1' # A label used to reference the doc
    )

    envelope_definition.documents = [document1]

    # Create the signer recipient model
    signer1 = DocuSign_eSign::Signer.new
    signer1.email = envelope_args[:signer_email]
    signer1.name = envelope_args[:signer_name]
    signer1.recipient_id = '1'
    signer1.routing_order = '1'
    signer1.access_code = args[:accessCode]

    sign_here1 = DocuSign_eSign::SignHere.new
    sign_here1.anchor_string = '/sn1/'
    sign_here1.anchor_units = 'pixels'
    sign_here1.anchor_x_offset = '20'
    sign_here1.anchor_y_offset = '10'

    # Add the tabs model (including the sign_here tabs) to the signer
    # The Tabs object takes arrays of the different field/tab types
    signer1_tabs = DocuSign_eSign::Tabs.new({
                                              signHereTabs: [sign_here1]
                                            })
    signer1.tabs = signer1_tabs

    # Add the recipients to the Envelope object
    recipients = DocuSign_eSign::Recipients.new(
      signers: [signer1]
    )
    # Request that the envelope be sent by setting |status| to "sent"
    # To request that the envelope be created as a draft, set to "created"
    envelope_definition.recipients = recipients
    envelope_definition.status = envelope_args[:status]
    #ds-snippet-end:eSign19Step3

    #ds-snippet-start:eSign19Step4
    envelope_api.create_envelope(args[:account_id], envelope_definition)
    #ds-snippet-end:eSign19Step4
  end
end
