require 'date'
require 'rubygems'
require 'test/unit'
require_relative './test_helper'
require_relative '../app/services/api_creator'
require_relative '../app/services/e_sign/eg031_bulk_sending_envelopes_service'

class Eg031BulkSendingEnvelopesTest < TestHelper
  setup do
    setup_test_data [api_type[:e_sign]]

    signers = {
      signer_email: @config['signer_email'],
      signer_name: @config['signer_name'],
      cc_email: @data[:cc_email],
      cc_name: @data[:cc_name],
      status: 'created',

      signer_email1: @data[:signer1_email],
      signer_name1: @data[:signer1_name],
      cc_email1: @data[:cc1_email],
      cc_name1: @data[:cc1_name],
    }
    args = {
      account_id: @account_id,
      base_path: @base_path,
      access_token: @access_token,
    }

    @eg031 = ESign::Eg031BulkSendingEnvelopesService.new(args, signers)
  end

  test 'should correctly bulk send the envelope if correct data is provided' do
    results = @eg031.worker

    assert_not_nil results
  end

  test 'should create correct bulk sending list if correct data is provided' do
    args = {
      signer_email: @config['signer_email'],
      signer_name: @config['signer_name'],
      cc_email: @data[:cc_email],
      cc_name: @data[:cc_name],
      status: 'created',

      signer_email1: @data[:signer1_email],
      signer_name1: @data[:signer1_name],
      cc_email1: @data[:cc1_email],
      cc_name1: @data[:cc1_name],
    }

    expected_bulk_sending_list = DocuSign_eSign::BulkSendingList.new(
      name: 'sample.csv',
      bulkCopies: [
        DocuSign_eSign::BulkSendingCopy.new(
          recipients: [
            DocuSign_eSign::BulkSendingCopyRecipient.new(
              roleName: 'signer',
              tabs: [],
              name: @config['signer_name'],
              email: @config['signer_email']
            ),
            DocuSign_eSign::BulkSendingCopyRecipient.new(
              roleName: 'cc',
              tabs: [],
              name: @data[:cc_name],
              email: @data[:cc_email]
            )
          ],
          custom_fields: []
        ),
        DocuSign_eSign::BulkSendingCopy.new(
          recipients: [
            DocuSign_eSign::BulkSendingCopyRecipient.new(
              roleName: 'signer',
              tabs: [],
              name: @data[:signer1_name],
              email: @data[:signer1_email]
            ),
            DocuSign_eSign::BulkSendingCopyRecipient.new(
              roleName: 'cc',
              tabs: [],
              name: @data[:cc1_name],
              email: @data[:cc1_email]
            )
          ],
          custom_fields: []
        )
      ]
    )

    results = @eg031.send(:create_bulk_sending_list, args)

    assert_not_nil results
    assert_equal expected_bulk_sending_list, results
  end

  test 'should create correct custom fields if correct data is provided' do
    bulk_list_id = 'bulk_list_id'

    expected_custom_fields = DocuSign_eSign::CustomFields.new(
      listCustomFields: [],
      textCustomFields: [
        DocuSign_eSign::TextCustomField.new(
          name: 'mailingListId',
          required: 'false',
          show: 'false',
          value: bulk_list_id
        )
      ]
    )

    results = @eg031.send(:custom_fields, bulk_list_id)

    assert_not_nil results
    assert_equal expected_custom_fields, results
  end

  test 'should correctly create envelope definition if correct data is provided' do
    expected_document = create_ds_document(@data[:doc_pdf], 'Lorem Ipsum', 'pdf', '2')

    expected_sign_here = DocuSign_eSign::SignHere.new
    expected_sign_here.anchor_string = '/sn1/'
    expected_sign_here.anchor_units = 'pixels'
    expected_sign_here.anchor_x_offset = '20'
    expected_sign_here.anchor_y_offset = '10'

    expected_signer_tabs = DocuSign_eSign::Tabs.new({
                                              signHereTabs: [expected_sign_here]
                                            })

    expected_signer = DocuSign_eSign::Signer.new
    expected_signer.name = 'Multi Bulk Recipient::signer'
    expected_signer.email = 'multiBulkRecipients-signer@docusign.com'
    expected_signer.role_name = 'signer'
    expected_signer.note = ''
    expected_signer.routing_order = 1
    expected_signer.status = 'created'
    expected_signer.delivery_method = 'email'
    expected_signer.recipient_id = '1'
    expected_signer.recipient_type = 'signer'
    expected_signer.tabs = expected_signer_tabs

    expected_cc = DocuSign_eSign::CarbonCopy.new
    expected_cc.name = 'Multi Bulk Recipient::cc'
    expected_cc.email = 'multiBulkRecipients-cc@docusign.com'
    expected_cc.role_name = 'cc'
    expected_cc.note = ''
    expected_cc.routing_order = 2
    expected_cc.status = 'created'
    expected_cc.delivery_method = 'email'
    expected_cc.recipient_id = '2'
    expected_cc.recipient_type = 'cc'

    expected_recipients = DocuSign_eSign::Recipients.new(
      signers: [expected_signer],
      carbonCopies: [expected_cc]
    )

    expected_envelope = DocuSign_eSign::EnvelopeDefinition.new
    expected_envelope.email_subject = 'Please sign this document set'
    expected_envelope.envelope_id_stamping = 'true'
    expected_envelope.documents = [expected_document]
    expected_envelope.recipients = expected_recipients
    expected_envelope.status = 'created'

    envelope = @eg031.send(:make_envelope)

    assert_not_nil envelope
    assert_equal expected_envelope, envelope
  end
end
