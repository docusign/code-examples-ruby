# frozen_string_literal: true

class Eg031Service
  include ApiCreator
  attr_reader :args, :signers

  def initialize(request, session)
    @signers = {
      signer_email: request.params['signerName'].gsub(/([^\w \-\@\.\,])+/, ''),
      signer_name: request.params['signerEmail'].gsub(/([^\w \-\@\.\,])+/, ''),
      cc_email: request.params['ccName'].gsub(/([^\w \-\@\.\,])+/, ''),
      cc_name: request.params['ccEmail'].gsub(/([^\w \-\@\.\,])+/, ''),
      status: 'created',

      signer_email1: request.params['signerName1'].gsub(/([^\w \-\@\.\,])+/, ''),
      signer_name1: request.params['signerEmail1'].gsub(/([^\w \-\@\.\,])+/, ''),
      cc_email1: request.params['ccName1'].gsub(/([^\w \-\@\.\,])+/, ''),
      cc_name1: request.params['ccEmail1'].gsub(/([^\w \-\@\.\,])+/, '')
    }
    @args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token']
    }
  end

  def call
    # Step 1. Obtain your OAuth token
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:base_path]
    api_client = DocuSign_eSign::ApiClient.new configuration

    # Step 2. Construct API headers
    construct_api_headers(api_client)

    #  Step 3. Create and submit bulk sending list
    bulk_envelopes_api = DocuSign_eSign::BulkEnvelopesApi.new api_client
    bulk_sending_list = create_bulk_sending_list
    bulk_list = bulk_envelopes_api.create_bulk_send_list(args[:account_id], bulk_sending_list)
    bulk_list_id  = bulk_list.list_id

    # Step 4. Create the draft envelope
    envelope_api = create_envelope_api(args)
    envelope_definition = create_envelope_api(args)
    envelope = envelope_api.create_envelope(args[:account_id], envelope_definition, options = DocuSign_eSign::CreateEnvelopeOptions.default)
    envelope_id = envelope.envelope_id

    # Step 5. Attach your bulk list ID to the envelope
    envelope_api.create_custom_fields(args[:account_id], envelope_id, custom_fields(bulk_list_id))

    # Step 6. Add placeholder recipients
    recipients = DocuSign_eSign::Recipients.new(signers: recipients_data)
    envelope_api.create_recipient(args[:account_id], envelope_id, recipients, options = DocuSign_eSign::CreateRecipientOptions.default)

     # Step 7. Initiate bulk send
    bulk_send_request = DocuSign_eSign::BulkSendRequest.new(envelopeOrTemplateId: envelope_id)
    batch = bulk_envelopes_api.create_bulk_send_request(args[:account_id], bulk_list_id, bulk_send_request)
    batch_id = batch.batch_id
  end

  private

  def construct_api_headers(api_client)
    api_client.default_headers['Authorization'] = "Bearer #{args[:access_token]}"
    api_client.default_headers['Content-Type'] = "application/json;charset=UTF-8"
    api_client.default_headers['Accept'] = "application/json, text/plain, */*"
    api_client.default_headers['Accept-Encoding'] = "gzip, deflate, br"
    api_client.default_headers['Accept-Language'] = "en-US,en;q=0.9"
  end

  def create_bulk_sending_list
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
    bulk_copies.append(bulk_copy1,  bulk_copy2)
    bulk_sending_list = DocuSign_eSign::BulkSendingList.new(
      name: "sample.csv",
      bulkCopies: bulk_copies
    )
    bulk_sending_list
  end

  def custom_fields(bulk_list_id)
    text_custom_fields = DocuSign_eSign::TextCustomField.new(
      name:'mailingListId',
      required: 'false',
      show: 'false',
      value: bulk_list_id
    )
    custom_fields = DocuSign_eSign::CustomFields.new(
      listCustomFields: [],
      textCustomFields: [text_custom_fields]
    )
  end

  def recipients_data
    signer = DocuSign_eSign::Signer.new(
      name: "Multi Bulk Recipient::signer",
      email: "multiBulkRecipients-signer@docusign.com",
      roleName: "signer",
      note: "",
      routingOrder: 1,
      status: "created",
      templateAccessCodeRequired: 'null',
      deliveryMethod: "email",
      recipientId: "10",
      recipientType: "signer"
    )

    cc = DocuSign_eSign::Signer.new(
      name: "Multi Bulk Recipient::cc",
      email: "multiBulkRecipients-cc@docusign.com",
      roleName: "cc",
      note: "",
      routingOrder: 1,
      status: "created",
      templateAccessCodeRequired: 'null',
      deliveryMethod: "email",
      recipientId: "11",
      recipientType: "signer"
    )
    [signer, cc]
  end
end