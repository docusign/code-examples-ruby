# frozen_string_literal: true

class ESign::Eg031BulkSendingEnvelopesService
  attr_reader :args, :signers

  include ApiCreator

  def initialize(args, signers)
    @args = args
    @signers = signers
  end

  def worker
    # Construct your API headers
    # Step 2 start
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:base_path]
    api_client = DocuSign_eSign::ApiClient.new configuration
    construct_api_headers(api_client, args)
    # Step end

    # Create and submit the bulk sending list
    # Step 3-1 start
    bulk_envelopes_api = DocuSign_eSign::BulkEnvelopesApi.new api_client
    bulk_sending_list = create_bulk_sending_list(signers)
    bulk_list = bulk_envelopes_api.create_bulk_send_list(args[:account_id], bulk_sending_list)
    bulk_list_id = bulk_list.list_id
    # Step 3-1 end

    # Create the draft envelope
    # Step 4-1 start
    envelope_api = create_envelope_api(args)
    envelope_definition = make_envelope
    envelope = envelope_api.create_envelope(args[:account_id], envelope_definition, DocuSign_eSign::CreateEnvelopeOptions.default)
    envelope_id = envelope.envelope_id
    # Step 4-1 end

    # Attach your bulk list ID to the envelope
    # Step 5-1 start
    envelope_api.create_custom_fields(args[:account_id], envelope_id, custom_fields(bulk_list_id))
    # Step 5-1 end

    # Initiate bulk send
    # Step 6 start
    bulk_send_request = DocuSign_eSign::BulkSendRequest.new(envelopeOrTemplateId: envelope_id)
    batch = bulk_envelopes_api.create_bulk_send_request(args[:account_id], bulk_list_id, bulk_send_request)
    batch_id = batch.batch_id
    # Step 6 end

    # Confirm successful batch send
    # Step 7 start
    bulk_envelopes_api.get_bulk_send_batch_status(args[:account_id], batch_id)
    # Step 7 end
  end

  private

  def construct_api_headers(api_client, args)
    api_client.default_headers['Authorization'] = "Bearer #{args[:access_token]}"
    api_client.default_headers['Content-Type'] = 'application/json;charset=UTF-8'
    api_client.default_headers['Accept'] = 'application/json, text/plain, */*'
    api_client.default_headers['Accept-Encoding'] = 'gzip, deflate, br'
    api_client.default_headers['Accept-Language'] = 'en-US,en;q=0.9'
  end

  # Step 3-2 start
  def create_bulk_sending_list(signers)
    bulk_copies = []
    recipient1 = DocuSign_eSign::BulkSendingCopyRecipient.new(
      roleName: 'signer',
      tabs: [],
      name: signers[:signer_name],
      email: signers[:signer_email]
    )

    # Create a cc recipient to receive a copy of the documents
    recipient2 = DocuSign_eSign::BulkSendingCopyRecipient.new(
      roleName: 'cc',
      tabs: [],
      name: signers[:cc_name],
      email: signers[:cc_email]
    )

    recipient3 = DocuSign_eSign::BulkSendingCopyRecipient.new(
      roleName: 'signer',
      tabs: [],
      name: signers[:signer_name1],
      email: signers[:signer_email1]
    )

    recipient4 = DocuSign_eSign::BulkSendingCopyRecipient.new(
      roleName: 'cc',
      tabs: [],
      name: signers[:cc_name1],
      email: signers[:cc_email1]
    )

    # Add the recipients to the envelope object
    bulk_copy1 = DocuSign_eSign::BulkSendingCopy.new(
      recipients: [recipient1, recipient2],
      custom_fields: []
    )

    bulk_copy2 = DocuSign_eSign::BulkSendingCopy.new(
      recipients: [recipient3, recipient4],
      custom_fields: []
    )
    bulk_copies.append(bulk_copy1, bulk_copy2)
    DocuSign_eSign::BulkSendingList.new(
      name: 'sample.csv',
      bulkCopies: bulk_copies
    )
  end
  # Step 3-2 end

  # Step 5-2 start
  def custom_fields(bulk_list_id)
    text_custom_fields = DocuSign_eSign::TextCustomField.new(
      name: 'mailingListId',
      required: 'false',
      show: 'false',
      value: bulk_list_id
    )
    DocuSign_eSign::CustomFields.new(
      listCustomFields: [],
      textCustomFields: [text_custom_fields]
    )
  end
  # Step 5-2 end

  # Step 4-2 start
  def make_envelope
    # Create the envelope definition
    envelope_definition = DocuSign_eSign::EnvelopeDefinition.new
    envelope_definition.email_subject = 'Please sign this document set'
    pdf_filename = 'World_Wide_Corp_lorem.pdf'
    # Add the documents
    doc = DocuSign_eSign::Document.new
    doc.document_base64 = Base64.encode64(File.binread(File.join('data', pdf_filename)))
    doc.name = 'Lorem Ipsum'
    doc.file_extension = 'pdf'
    doc.document_id = '2'

    signer = DocuSign_eSign::Signer.new(
      name: 'Multi Bulk Recipient::signer',
      email: 'multiBulkRecipients-signer@docusign.com',
      roleName: 'signer',
      note: '',
      routingOrder: 1,
      status: 'created',
      templateAccessCodeRequired: 'null',
      deliveryMethod: 'email',
      recipientId: '1',
      recipientType: 'signer'
    )

    cc = DocuSign_eSign::CarbonCopy.new(
      name: 'Multi Bulk Recipient::cc',
      email: 'multiBulkRecipients-cc@docusign.com',
      roleName: 'cc',
      note: '',
      routingOrder: 2,
      status: 'created',
      deliveryMethod: 'email',
      recipientId: '2',
      recipientType: 'cc'
    )

    # The DocuSign platform searches throughout your envelope's documents for matching
    # anchor strings. So the sign_here_2 tab will be used in both document 2 and 3
    # since they use the same anchor string for their "signer 1" tabs.
    sign_here = DocuSign_eSign::SignHere.new
    sign_here.anchor_string = '/sn1/'
    sign_here.anchor_units = 'pixels'
    sign_here.anchor_x_offset = '20'
    sign_here.anchor_y_offset = '10'
    # Tabs are set per recipient/signer
    tabs = DocuSign_eSign::Tabs.new
    tabs.sign_here_tabs = [sign_here]
    signer.tabs = tabs

    # Add the recipients to the envelope object
    recipients = DocuSign_eSign::Recipients.new(
      signers: [signer],
      carbonCopies: [cc]
    )

    envelope_definition.recipients = recipients
    # The order in the docs array determines the order in the envelope
    envelope_definition.documents = [doc]
    envelope_definition.envelope_id_stamping = 'true'
    envelope_definition.status = 'created'
    envelope_definition
  end
  # Step 4-2 end
end
