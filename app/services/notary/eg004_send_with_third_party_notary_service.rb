# frozen_string_literal: true

class Notary::Eg004SendWithThirdPartyNotaryService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    # Create the envelope request object
    #ds-snippet-start:Notary4Step4
    envelope_definition = make_envelope args[:envelope_args]
    # Call Envelopes::create API method
    # Exceptions will be caught by the calling function
    envelope_api = create_envelope_api(args)

    results, _status, headers = envelope_api.create_envelope_with_http_info args[:account_id], envelope_definition

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end

    envelope_id = results.envelope_id
    { 'envelope_id' => envelope_id }
    #ds-snippet-end:Notary4Step4
  end

  private

  #ds-snippet-start:Notary4Step3
  def make_envelope(envelope_args)
    # The envelope has two recipients:
    # recipient 1 - notary
    # recipient 2 - signer
    # The envelope will be sent first to the signer.
    # After it is signed, a copy is sent to the cc person

    # Create the envelope definition
    envelope_definition = DocuSign_eSign::EnvelopeDefinition.new

    envelope_definition.email_subject = 'Please sign this document set'

    # Add the document
    doc_b64 = Base64.encode64(File.binread(envelope_args[:doc_path]))

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

    sign_here_1 = DocuSign_eSign::SignHere.new(
      documentId: '1',
      xPosition: '200',
      yPosition: '235',
      pageNumber: '1'
    )
    sign_here_2 = DocuSign_eSign::SignHere.new(
      stampType: 'stamp',
      documentId: '1',
      xPosition: '200',
      yPosition: '150',
      pageNumber: '1'
    )

    # Add the tabs model (including the sign_here tabs) to the signer
    # The Tabs object takes arrays of the different field/tab types
    signer_tab = DocuSign_eSign::Tabs.new(
      signHereTabs: [sign_here_1, sign_here_2]
    )

    # Create the signer recipient model
    signer = DocuSign_eSign::Signer.new(
      clientUserId: '1000',
      email: envelope_args[:signer_email],
      name: envelope_args[:signer_name],
      recipientId: '2',
      routingOrder: '1',
      notaryId: '1',
      tabs: signer_tab
    )

    notary_seal = DocuSign_eSign::NotarySeal.new(
      xPosition: '300',
      yPosition: '235',
      documentId: '1',
      pageNumber: '1'
    )

    notary_sign_here = DocuSign_eSign::SignHere.new(
      xPosition: '300',
      yPosition: '150',
      documentId: '1',
      pageNumber: '1'
    )

    notary_tabs = DocuSign_eSign::Tabs.new(
      signHereTabs: [notary_sign_here],
      notarySealTabs: [notary_seal]
    )

    notary_recipient = DocuSign_eSign::NotaryRecipient.new(
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
      notaries: [notary_recipient]
    )
    # Request that the envelope be sent by setting status to "sent".
    # To request that the envelope be created as a draft, set status to "created"
    envelope_definition.recipients = recipients
    envelope_definition.status = 'sent'
    envelope_definition
  end
  #ds-snippet-end:Notary4Step3
end
