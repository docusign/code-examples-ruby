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
    #ds-snippet-start:eSign31Step2
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:base_path]
    api_client = DocuSign_eSign::ApiClient.new configuration
    construct_api_headers(api_client, args)
    #ds-snippet-end:eSign31Step2

    # Create and submit the bulk sending list
    #ds-snippet-start:eSign31Step3
    bulk_envelopes_api = DocuSign_eSign::BulkEnvelopesApi.new api_client
    bulk_sending_list = create_bulk_sending_list(signers)
    bulk_list, _status, headers = bulk_envelopes_api.create_bulk_send_list_with_http_info(args[:account_id], bulk_sending_list)

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end

    bulk_list_id = bulk_list.list_id
    #ds-snippet-end:eSign31Step3

    # Create the draft envelope
    #ds-snippet-start:eSign31Step4
    envelope_api = create_envelope_api(args)
    envelope_definition = make_envelope
    envelope, _status, headers = envelope_api.create_envelope_with_http_info(args[:account_id], envelope_definition, DocuSign_eSign::CreateEnvelopeOptions.default)

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end

    envelope_id = envelope.envelope_id
    #ds-snippet-end:eSign31Step4

    # Attach your bulk list ID to the envelope
    #ds-snippet-start:eSign31Step5
    _results, _status, headers = envelope_api.create_custom_fields_with_http_info(args[:account_id], envelope_id, custom_fields(bulk_list_id))

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:eSign31Step5

    # Initiate bulk send
    #ds-snippet-start:eSign31Step6
    bulk_send_request = DocuSign_eSign::BulkSendRequest.new(envelopeOrTemplateId: envelope_id)
    batch, _status, headers = bulk_envelopes_api.create_bulk_send_request_with_http_info(args[:account_id], bulk_list_id, bulk_send_request)

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end

    batch_id = batch.batch_id
    #ds-snippet-end:eSign31Step6

    # Confirm successful batch send
    #ds-snippet-start:eSign31Step7
    results, _status, headers = bulk_envelopes_api.get_bulk_send_batch_status_with_http_info(args[:account_id], batch_id)

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:eSign31Step7

    results
  end

  private

  def construct_api_headers(api_client, args)
    api_client.default_headers['Authorization'] = "Bearer #{args[:access_token]}"
    api_client.default_headers['Content-Type'] = 'application/json;charset=UTF-8'
    api_client.default_headers['Accept'] = 'application/json, text/plain, */*'
    api_client.default_headers['Accept-Encoding'] = 'gzip, deflate, br'
    api_client.default_headers['Accept-Language'] = 'en-US,en;q=0.9'
  end

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

    # The Docusign platform searches throughout your envelope's documents for matching
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
end
