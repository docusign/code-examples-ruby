# frozen_string_literal: true

class ESign::Eg041CfrEmbeddedSigningService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  # ***DS.snippet.0.start
  def worker
    envelope_args = args[:envelope_args]
    accounts_api = create_account_api(args)

    # Obtain your workflow_id
    workflow_results = accounts_api.get_account_identity_verification(args[:account_id])

    if workflow_results.identity_verification
      workflow = workflow_results.identity_verification.find { |item| item.default_name == 'SMS for access & signatures' }
      workflow_id = workflow.workflow_id if workflow
    end

    return 'invalid_workflow_id' if workflow_id.blank?

    envelope_api = create_envelope_api(args)
    envelope_definition = make_envelope(args[:envelope_args], workflow_id)

    envelope = envelope_api.create_envelope(args[:account_id], envelope_definition)

    envelope_id = envelope.envelope_id

    view_request = DocuSign_eSign::RecipientViewRequest.new({
                                                              returnUrl: "#{envelope_args[:ds_return_url]}?state=123",
                                                              authenticationMethod: 'none',
                                                              email: envelope_args[:signer_email],
                                                              userName: envelope_args[:signer_name],
                                                              clientUserId: envelope_args[:signer_client_id],
                                                              pingFrequency: 600,
                                                              pingUrl: envelope_args[:ds_ping_url]
                                                            })

    results = envelope_api.create_recipient_view(args[:account_id], envelope_id, view_request)

    results.url
  end

  private

  def make_envelope(args, workflow_id)
    envelope_definition = DocuSign_eSign::EnvelopeDefinition.new
    envelope_definition.email_subject = 'Please sign this document sent from Ruby SDK'

    doc1 = DocuSign_eSign::Document.new
    doc1.document_base64 = Base64.encode64(File.binread(args[:pdf_filename]))
    doc1.name = 'Lorem Ipsum'
    doc1.file_extension = 'pdf'
    doc1.document_id = '1'

    # The order in the docs array determines the order in the envelope
    envelope_definition.documents = [doc1]

    phone_number = DocuSign_eSign::RecipientIdentityPhoneNumber.new
    phone_number.country_code = args[:country_code]
    phone_number.number = args[:phone_number]

    input_option = DocuSign_eSign::RecipientIdentityInputOption.new
    input_option.name = 'phone_number_list'
    input_option.value_type = 'PhoneNumberList'
    input_option.phone_number_list = [phone_number]

    identity_verification = DocuSign_eSign::RecipientIdentityVerification.new

    identity_verification.workflow_id = workflow_id
    identity_verification.input_options = [input_option]

    # Create a signer recipient to sign the document, identified by name and email
    # We're setting the parameters via the object creation
    signer1 = DocuSign_eSign::Signer.new({
                                           email: args[:signer_email],
                                           name: args[:signer_name],
                                           clientUserId: args[:signer_client_id],
                                           recipientId: 1,
                                           identityVerification: identity_verification
                                         })
    # The DocuSign platform searches throughout your envelope's documents for matching
    # anchor strings. So the sign_here_2 tab will be used in both document 2 and 3
    # since they use the same anchor string for their "signer 1" tabs.
    sign_here = DocuSign_eSign::SignHere.new
    sign_here.anchor_string = '/sn1/'
    sign_here.anchor_units = 'pixels'
    sign_here.anchor_x_offset = '20'
    sign_here.anchor_y_offset = '-30'
    # Tabs are set per recipient/signer
    tabs = DocuSign_eSign::Tabs.new
    tabs.sign_here_tabs = [sign_here]
    signer1.tabs = tabs
    # Add the recipients to the envelope object
    recipients = DocuSign_eSign::Recipients.new
    recipients.signers = [signer1]

    envelope_definition.recipients = recipients
    # Request that the envelope be sent by setting status to "sent".
    # To request that the envelope be created as a draft, set status to "created"
    envelope_definition.status = 'sent'
    envelope_definition
  end
  # ***DS.snippet.0.end
end
