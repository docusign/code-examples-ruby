# frozen_string_literal: true

class ESign::Eg034UseConditionalRecipientsService
  include ApiCreator
  attr_reader :args, :signers

  def initialize(session, request)
    @signers = {
      signerEmail1: request['signerEmail1'],
      signerName1: request['signerName1'],

      signerEmailNotChecked: request['signerEmailNotChecked'],
      signerNameNotChecked: request['signerNameNotChecked'],

      signerEmailChecked: request['signerEmailChecked'],
      signerNameChecked: request['signerNameChecked']
    }

    @args = {
      accountId: session['ds_account_id'],
      basePath: session['ds_base_path'],
      accessToken: session['ds_access_token']
    }
  end

  def call
    # Step 2. Construct your API headers
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:basePath]
    api_client = DocuSign_eSign::ApiClient.new configuration
    api_client.set_default_header('Authorization', "Bearer #{args[:accessToken]}")

    # Step 3. Construct the request body
    envelope_definition = DocuSign_eSign::EnvelopeDefinition.new(emailSubject: 'ApproveIfChecked')

    # Create the document model.
    documents = [
      DocuSign_eSign::Document.new(
        documentBase64: 'VGhhbmtzIGZvciByZXZpZXdpbmcgdGhpcyEKCldlJ2xsIG1vdmUgZm9yd2FyZCBhcyBzb29uIGFzIHdlIGhlYXIgYmFjay4=',
        documentId: 1,
        fileExtension: 'txt',
        name: 'Welcome'
      )
    ]
    envelope_definition.documents = documents

    # Create the signer model
    # routingOrder (lower means earlier) determines the order of deliveries to the recipients
    signer_1 = DocuSign_eSign::Signer.new(
      email: signers[:signerEmail1],
      name: signers[:signerName1],
      recipientId: 1,
      routingOrder: 1,
      roleName: 'Purchaser'
    )
    signer_2 = DocuSign_eSign::Signer.new(
      email: 'placeholder@example.com',
      name: 'Approver',
      recipientId: 2,
      routingOrder: 2,
      roleName: 'Approver'
    )

    # Create signHere field (also known as tabs) on the documents
    sign_here_1 = DocuSign_eSign::SignHere.new(
      documentId: 1,
      pageNumber: 1,
      name: 'SignHere',
      tabLabel: 'PurchaserSignature',
      xPosition: 200,
      yPosition: 200
    )
    sign_here_2 = DocuSign_eSign::SignHere.new(
      documentId: 1,
      pageNumber: 1,
      name: 'SignHere',
      recipientId: 2,
      tabLabel: 'ApproverSignature',
      xPosition: 300,
      yPosition: 200
    )

    # Create checkbox field on the documents
    checkbox = DocuSign_eSign::Checkbox.new(
      documentId: 1,
      pageNumber: 1,
      name: 'ClickToApprove',
      selected: false,
      tabLabel: 'ApproveWhenChecked',
      xPosition: 50,
      yPosition: 50
    )

    # Add the tabs models (including the sign_here tabs) to the signer
    # The Tabs object wants arrays of the different field/tab types
    signer_1.tabs = DocuSign_eSign::Tabs.new(
      signHereTabs: [sign_here_1],
      checkboxTabs: [checkbox]
    )
    signer_2.tabs = DocuSign_eSign::Tabs.new(
      signHereTabs: [sign_here_2]
    )

    # Add the recipients to the envelope object
    env_recipients = DocuSign_eSign::Recipients.new(signers: [signer_1, signer_2])
    envelope_definition.recipients = env_recipients

    # Create recipientOption models
    signer_2a = DocuSign_eSign::RecipientOption.new(
      email: signers[:signerEmailNotChecked],
      name: signers[:signerNameNotChecked],
      roleName: 'Signer when not checked',
      recipientLabel: 'signer2a'
    )
    signer_2b = DocuSign_eSign::RecipientOption.new(
      email: signers[:signerEmailChecked],
      name: signers[:signerNameChecked],
      roleName: 'Signer when checked',
      recipientLabel: 'signer2b'
    )
    recipients = [signer_2a, signer_2b]

    # Create recipientGroup model
    recipient_group = DocuSign_eSign::RecipientGroup.new(
      groupName: 'Approver',
      groupMessage: 'Members of this group approve a workflow',
      recipients: recipients
    )

    # Create conditionalRecipientRuleFilter models
    filter1 = DocuSign_eSign::ConditionalRecipientRuleFilter.new(
      scope: 'tabs',
      recipientId: 1,
      tabId: 'ApprovalTab',
      operator: 'equals',
      value: false,
      tabLabel: 'ApproveWhenChecked',
      tabType: 'checkbox'
    )
    filter2 = DocuSign_eSign::ConditionalRecipientRuleFilter.new(
      scope: 'tabs',
      recipientId: 1,
      tabId: 'ApprovalTab',
      operator: 'equals',
      value: true,
      tabLabel: 'ApproveWhenChecked',
      tabType: 'checkbox'
    )

    # Create conditionalRecipientRuleCondition models
    condition1 = DocuSign_eSign::ConditionalRecipientRuleCondition.new(
      filters: [filter1],
      order: 1,
      recipientLabel: 'signer2a'
    )
    condition2 = DocuSign_eSign::ConditionalRecipientRuleCondition.new(
      filters: [filter2],
      order: 2,
      recipientLabel: 'signer2b'
    )
    conditions = [condition1, condition2]

    # Create conditionalRecipientRule model
    conditional_recipient = DocuSign_eSign::ConditionalRecipientRule.new(
      conditions: conditions,
      recipientGroup: recipient_group,
      recipientId: 2,
      order: 0
    )

    # Create recipientRules model
    rules = DocuSign_eSign::RecipientRules.new(conditionalRecipients: [conditional_recipient])
    recipient_routing = DocuSign_eSign::RecipientRouting.new(rules: rules)

    # Create a workflow model
    workflow_step = DocuSign_eSign::WorkflowStep.new(
      action: 'pause_before',
      triggerOnItem: 'routing_order',
      itemId: 2,
      status: 'pending',
      recipientRouting: recipient_routing
    )
    workflow = DocuSign_eSign::Workflow.new(workflowSteps: [workflow_step])
    # Add the workflow to the envelope object
    envelope_definition.workflow = workflow

    # Request that the envelope be sent by setting |status| to "sent"
    # To request that the envelope be created as a draft, set to "created"
    envelope_definition.status = 'sent'

    # Step 4. Call the eSignature API
    envelopes_api = DocuSign_eSign::EnvelopesApi.new(api_client)

    results = envelopes_api.create_envelope(
      args[:accountId],
      envelope_definition
    )
  end
end
