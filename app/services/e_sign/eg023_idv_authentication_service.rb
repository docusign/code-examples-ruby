# frozen_string_literal: true

class ESign::Eg023IdvAuthenticationService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    envelope_args = args[:envelope_args]

    # Obtain your workflow ID
    #ds-snippet-start:eSign23Step3
    accounts_api = create_account_api(args)
    workflow_response = accounts_api.get_account_identity_verification args[:account_id]
    if workflow_response.identity_verification
      idv_workflow = workflow_response.identity_verification.find { |item| item.default_name == 'DocuSign ID Verification' }
      workflow_id = idv_workflow.workflow_id if idv_workflow
    end
    ##ds-snippet-end:eSign23Step3

    return 'idv_not_enabled' if workflow_id.blank?

    puts 'WORKFLOW ID: '
    puts workflow_id

    # Construct your envelope JSON body
    #ds-snippet-start:eSign23Step4
    envelope_definition = DocuSign_eSign::EnvelopeDefinition.new
    envelope_definition.email_subject = 'Please sign this document set'

    # Add the documents
    pdf_filename = 'World_Wide_Corp_lorem.pdf'

    # Create the document models
    document1 = DocuSign_eSign::Document.new(
      # Create the Docusign Document object
      documentBase64: Base64.encode64(File.binread(File.join('data', pdf_filename))),
      name: 'Lorem', # Can be different from the actual file name
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

    wf = DocuSign_eSign::RecipientIdentityVerification.new
    wf.workflow_id = workflow_id
    signer1.identity_verification = wf

    # Add the recipients to the Envelope object
    recipients = DocuSign_eSign::Recipients.new(
      signers: [signer1]
    )
    # Request that the envelope be sent by setting status to "sent"
    # To request that the envelope be created as a draft, set status to "created"
    envelope_definition.recipients = recipients
    envelope_definition.status = envelope_args[:status]
    #ds-snippet-end:eSign23Step4

    # Call the eSignature REST API
    #ds-snippet-start:eSign23Step5
    envelope_api = create_envelope_api(args)
    envelope_api.create_envelope args[:account_id], envelope_definition
    #ds-snippet-end:eSign23Step5
  end
end
