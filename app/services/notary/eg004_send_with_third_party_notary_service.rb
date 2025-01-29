# frozen_string_literal: true

class Notary::Eg004SendWithThirdPartyNotaryService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  #ds-snippet-start:Notary4Step3
  def worker
    # Create the envelope request object
    envelope_definition = make_envelope args[:envelope_args]
    # Call Envelopes::create API method
    # Exceptions will be caught by the calling function
    envelope_api = create_envelope_api(args)

    results = envelope_api.create_envelope args[:account_id], envelope_definition
    envelope_id = results.envelope_id
    { 'envelope_id' => envelope_id }
  end
  #ds-snippet-end:Notary4Step3

  private

  #ds-snippet-start:Notary4Step2
  def make_envelope(envelope_args)
    # document 1 (HTML) has tag **signature_1**
    # document 2 (DOCX) has tag /sn1/
    # document 3 (PDF) has tag /sn1/
    #
    # The envelope has two recipients:
    # recipient 1 - signer
    # recipient 2 - cc
    # The envelope will be sent first to the signer.
    # After it is signed, a copy is sent to the cc person

    # Create the envelope definition
    envelope_definition = DocuSign_eSign::EnvelopeDefinition.new

    envelope_definition.email_subject = 'Please sign this document set'

    # Add the document
    doc_b64 = Base64.encode64(File.binread(envelope_args[:doc_pdf]))

    # Create the document model
    document = DocuSign_eSign::Document.new(
      # Create the Docusign document object
      documentBase64: doc_b64,
      name: 'Order acknowledgement', # Can be different from actual file name
      fileExtension: 'html', # Many different document types are accepted
      documentId: '1' # A label used to reference the doc
    )

    # The order in the docs array determines the order in the envelope
    envelope_definition.documents = [document]

    # Create the signer recipient model
    signer = DocuSign_eSign::Signer.new
    signer.email = envelope_args[:signer_email]
    signer.name = envelope_args[:signer_name]
    signer.recipient_id = '1'
    signer.routing_order = '1'
    ## routingOrder (lower means earlier) determines the order of deliveries
    # to the recipients. Parallel routing order is supported by using the
    # same integer as the order for two or more recipients

    # Create signHere fields (also known as tabs) on the documents
    # We're using anchor (autoPlace) positioning
    #
    # The Docusign platform searches throughout your envelope's documents for matching
    # anchor strings. So the sign_here_2 tab will be used in both document 2 and 3
    # since they use the same anchor string for their "signer 1" tabs.
    sign_here = DocuSign_eSign::SignHere.new(
      anchorString: '/sn1/',
      anchorYOffset: '10',
      anchorUnits: 'pixels',
      anchorXOffset: '20'
    )

    # Add the tabs model (including the sign_here tabs) to the signer
    # The Tabs object takes arrays of the different field/tab types
    signer_tab = DocuSign_eSign::Tabs.new({
                                            signHereTabs: [sign_here]
                                          })

    signer.tabs = signer_tab

    notary_seal = DocuSign_eSign::NotarySeal.new(
      xPosition: '300',
      yPosition: '235',
      documentId: '1',
      pageNumber: '1',
    )

    notary_sign_here = DocuSign_eSign::SignHere.new(
      xPosition: '300',
      yPosition: '150',
      documentId: '1',
      pageNumber: '1',
    )

    notary_tabs = DocuSign_eSign::Tabs.new(
      signHereTabs: [notary_sign_here],
      notarySealTabs: [notary_seal]
    )

    notary_recipient = DocuSign_eSign::NotaryRecipient.new(
      email: '',
      name: 'Notary',
      recipientId: '1',
      routingOrder: '1',
      tabs: notary_tabs,
      notaryType: 'remote',
      notarySourceType: 'thirdparty',
      notaryThirdPartyPartner: 'onenotary',
      recipientSignatureProviders: [
        {
          sealDocumentsWithTabsOnly: 'false',
          signatureProviderName: 'ds_authority_idv',
          signatureProviderOptions: {}
        }
      ]
    )

    # Add the recipients to the envelope object
    recipients = DocuSign_eSign::Recipients.new(
      signers: [signer],
      notary: [notary_recipient]
    )
    # Request that the envelope be sent by setting status to "sent".
    # To request that the envelope be created as a draft, set status to "created"
    envelope_definition.recipients = recipients
    envelope_definition.status = 'sent'
    envelope_definition
  end
  #ds-snippet-end:Notary4Step2
end
