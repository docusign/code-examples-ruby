# frozen_string_literal: true

class ESign::Eg036DelayedRoutingService
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
    signer1.email = envelope_args[:signer1_email]
    signer1.name = envelope_args[:signer1_name]
    signer1.recipient_id = '1'
    signer1.routing_order = '1'
    ## routingOrder (lower means earlier) determines the order of deliveries
    # to the recipients. Parallel routing order is supported by using the
    # same integer as the order for two or more recipients

    signer2 = DocuSign_eSign::Signer.new
    signer2.email = envelope_args[:signer2_email]
    signer2.name = envelope_args[:signer2_name]
    signer2.recipient_id = '2'
    signer2.routing_order = '2'

    # Create signHere fields (also known as tabs) on the document
    # We're using anchor (autoPlace) positioning for the sign_here1 tab
    # and we're using absolute positioning for the sign_here2 tab.
    #
    # The DocuSign platform searches throughout your envelope's documents for matching
    # anchor strings.
    sign_here1 = DocuSign_eSign::SignHere.new(
      anchorString: '/sn1/',
      anchorYOffset: '10',
      anchorUnits: 'pixels',
      anchorXOffset: '20'
    )

    sign_here2 = DocuSign_eSign::SignHere.new(
      xPosition: "320",
      yPosition: "175",
      pageNumber: "1",
      documentId: "1"
    )

    # Add the tabs model (including the sign_here tabs) to the signer
    # The Tabs object takes arrays of the different field/tab types
    signer1_tabs = DocuSign_eSign::Tabs.new({
      signHereTabs: [sign_here1]
    })

    signer2_tabs = DocuSign_eSign::Tabs.new({
      signHereTabs: [sign_here2]
    })

    signer1.tabs = signer1_tabs
    signer2.tabs = signer2_tabs

    # Add the recipients to the envelope object
    recipients = DocuSign_eSign::Recipients.new(
      signers: [signer1, signer2]
    )

    envelope_definition.recipients = recipients

    # Create recipientRules model
    delay_time = "0." + envelope_args[:delay].to_s + ":00:00";
    rule = DocuSign_eSign::EnvelopeDelayRuleApiModel.new(delay: delay_time)

    delayed_routing = DocuSign_eSign::DelayedRoutingApiModel.new(rules: [rule])

    # Create a workflow model
    workflow_step = DocuSign_eSign::WorkflowStep.new(
      action: 'pause_before',
      triggerOnItem: 'routing_order',
      itemId: 2,
      delayedRouting: delayed_routing
    )
    workflow = DocuSign_eSign::Workflow.new(workflowSteps: [workflow_step])
    # Add the workflow to the envelope object
    envelope_definition.workflow = workflow

    # Request that the envelope be sent by setting status to "sent".
    # To request that the envelope be created as a draft, set status to "created"
    envelope_definition.status = envelope_args[:status]
    envelope_definition
  end
end