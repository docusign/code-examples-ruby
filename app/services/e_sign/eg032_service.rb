# frozen_string_literal: true

class ESign::Eg032Service
  include ApiCreator
  attr_reader :args, :signers

  def initialize(session, request)
    @signers = {
      signerEmail1: request['signerEmail1'],
      signerName1: request['signerName1'],

      signerEmail2: request['signerEmail2'],
      signerName2: request['signerName2']
    }

    @args = {
      accountId: session['ds_account_id'],
      basePath: session['ds_base_path'],
      accessToken: session['ds_access_token'],
      status: 'sent'
    }
  end

  def call
    # Step 2. Construct your API headers
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:basePath]

    api_client = DocuSign_eSign::ApiClient.new configuration
    api_client.set_default_header('Authorization', "Bearer #{args[:accessToken]}")

    # Step 3. Construct the request body
    envelope_definition = DocuSign_eSign::EnvelopeDefinition.new(emailSubject: 'EnvelopeWorkflowTest')

    # Create the document model.
    document = DocuSign_eSign::Document.new(
      documentBase64: 'DQoNCg0KDQoJCVdlbGNvbWUgdG8gdGhlIERvY3VTaWduIFJlY3J1aXRpbmcgRXZlbnQNCgkJDQoJCQ0KCQlQbGVhc2UgU2lnbiBpbiENCgkJDQoJCQ0KCQk=',
      documentId: 1,
      fileExtension: 'txt',
      name: 'Welcome'
    )

    # The order in the docs array determines the order in the envelope.
    envelope_definition.documents = [document]

    # Create the signer recipient models
    # routing_order (lower means earlier) determines the order of deliveries
    # to the recipients.
    signer_1 = DocuSign_eSign::Signer.new(
      email: signers[:signerEmail1],
      name: signers[:signerName1],
      recipientId: 1,
      routingOrder: 1
    )
    signer_2 = DocuSign_eSign::Signer.new(
      email: signers[:signerEmail2],
      name: signers[:signerName2],
      recipientId: 2,
      routingOrder: 2
    )

    # Create SignHere fields (also known as tabs) on the documents.
    sign_here_1 = DocuSign_eSign::SignHere.new(
      documentId: 1,
      pageNumber: 1,
      tabLabel: 'Sign Here',
      xPosition: 200,
      yPosition: 200
    )
    sign_here_2 = DocuSign_eSign::SignHere.new(
      documentId: 1,
      pageNumber: 1,
      tabLabel: 'Sign Here',
      xPosition: 300,
      yPosition: 200
    )

    # Add the tabs models (including the sign_here tabs) to the signer
    # The Tabs object uses arrays of the different field/tab types
    signer_1.tabs = DocuSign_eSign::Tabs.new(
      signHereTabs: [sign_here_1]
    )
    signer_2.tabs = DocuSign_eSign::Tabs.new(
      signHereTabs: [sign_here_2]
    )

    # Add the recipients to the envelope object
    recipients = DocuSign_eSign::Recipients.new(signers: [signer_1, signer_2])
    envelope_definition.recipients = recipients

    # Create a workflow model
    # Signature workflow will be paused after it is signed by the first signer
    workflow_step = DocuSign_eSign::WorkflowStep.new(
      action: 'pause_before',
      triggerOnItem: 'routing_order',
      itemId: 2
    )
    workflow = DocuSign_eSign::Workflow.new(workflowSteps: [workflow_step])
    envelope_definition.workflow = workflow

    # Request that the envelope be sent by setting |status| to "sent"
    # To request that the envelope be created as a draft, set to "created"
    envelope_definition.status = args[:status]

    # Step 4. Call the eSignature API
    envelopes_api = DocuSign_eSign::EnvelopesApi.new(api_client)
    results = envelopes_api.create_envelope(
      args[:accountId],
      envelope_definition
    )
  end
end
