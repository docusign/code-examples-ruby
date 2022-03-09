# frozen_string_literal: true

class ESign::Eg035ScheduledSendingService
  attr_reader :args
  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    # 1. Create the envelope request object
    envelope_definition = make_envelope args[:envelope_args]
    # 2. Call Envelopes::create API method
    # Exceptions will be caught by the calling function
    envelope_api = create_envelope_api(args)

    results = envelope_api.create_envelope args[:account_id], envelope_definition
    envelope_id = results.envelope_id
    { 'envelope_id' => envelope_id }
  end

  private

  def make_envelope(envelope_args)
    # document (PDF) has tag /sn1/
    # The envelope has one recipient

    # Create the envelope definition
    envelope_definition = DocuSign_eSign::EnvelopeDefinition.new

    envelope_definition.email_subject = 'Please sign this document'

    # Add the document
    # Read file from a local directory
    # The reads could raise an exception if the file is not available!
    doc_pdf = Rails.application.config.doc_pdf
    doc_b64 = Base64.encode64(File.binread(File.join('data', doc_pdf)))

    # Create the document model
    document = DocuSign_eSign::Document.new(
      # Create the DocuSign document object
      documentBase64: doc_b64,
      name: 'Lorem Ipsum', # Can be different from actual file name
      fileExtension: 'pdf', # Many different document types are accepted
      documentId: '1' # A label used to reference the doc
    )

    # The order in the docs array determines the order in the envelope
    envelope_definition.documents = [document]

    # Create the signer recipient model
    signer1 = DocuSign_eSign::Signer.new
    signer1.email = envelope_args[:signer_email]
    signer1.name = envelope_args[:signer_name]
    signer1.recipient_id = '1'
    signer1.routing_order = '1'
    ## routingOrder (lower means earlier) determines the order of deliveries
    # to the recipients. Parallel routing order is supported by using the
    # same integer as the order for two or more recipients

    # Create a signHere field (also known as a tab) on the document
    # We're using anchor (autoPlace) positioning
    #
    # The DocuSign platform searches throughout your envelope's documents for matching
    # anchor strings.
    sign_here = DocuSign_eSign::SignHere.new(
      anchorString: '/sn1/',
      anchorYOffset: '10',
      anchorUnits: 'pixels',
      anchorXOffset: '20'
    )
    # Add the tabs model (including the sign_here tabs) to the signer
    # The Tabs object takes arrays of the different field/tab types
    signer1_tabs = DocuSign_eSign::Tabs.new({
      signHereTabs: [sign_here]
    })

    signer1.tabs = signer1_tabs

    # Add the recipients to the envelope object
    recipients = DocuSign_eSign::Recipients.new(
      signers: [signer1]
    )
    envelope_definition.recipients = recipients

    # Create recipientRules model
    rule = DocuSign_eSign::EnvelopeDelayRuleApiModel.new(
      resumeDate: envelope_args[:resume_date].to_s
    )

    scheduled_sending = DocuSign_eSign::ScheduledSendingApiModel.new(
      rules: [rule]
    )

    workflow = DocuSign_eSign::Workflow.new(scheduledSending: scheduled_sending)
    # Add the workflow to the envelope object
    envelope_definition.workflow = workflow

    # Request that the envelope be sent by setting status to "sent".
    # To request that the envelope be created as a draft, set status to "created"
    envelope_definition.status = envelope_args[:status]
    envelope_definition
  end
end