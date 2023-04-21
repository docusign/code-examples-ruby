require 'date'
require 'rubygems'
require 'test/unit'
require_relative './test_helper'
require_relative '../app/services/api_creator'
require_relative '../app/services/e_sign/eg029_brands_apply_to_envelope_service'

class Eg029BrandsApplyToEnvelopeTest < TestHelper
  setup do
    setup_test_data [api_type[:e_sign]]

    envelope_args = {
      signer_email: @config['signer_email'],
      signer_name: @config['signer_name'],
      brand_id: TestData.get_brand_id,
      status: 'sent'
    }
    args = {
      account_id: @account_id,
      base_path: @base_path,
      access_token: @access_token,
      envelope_args: envelope_args
    }

    @eg029 = ESign::Eg029BrandsApplyToEnvelopeService.new(args)
  end

  test 'should correctly apply brand to envelope if correct data is provided' do
    results = @eg029.worker

    assert_not_nil results
  end

  test 'should correctly create envelope definition if correct data is provided' do
    args = {
      signer_email: @config['signer_email'],
      signer_name: @config['signer_name'],
      brand_id: TestData.get_brand_id,
      status: 'sent'
    }

    expected_document = create_ds_document(@data[:doc_pdf], 'NDA', 'pdf', '1')

    expected_signer = DocuSign_eSign::Signer.new
    expected_signer.name = @config['signer_name']
    expected_signer.email = @config['signer_email']
    expected_signer.role_name = 'signer'
    expected_signer.note = ''
    expected_signer.routing_order = '1'
    expected_signer.status = args[:status]
    expected_signer.delivery_method = 'email'
    expected_signer.recipient_id = '1'

    expected_sign_here = DocuSign_eSign::SignHere.new
    expected_sign_here.document_id = '1'
    expected_sign_here.name = 'SignHereTab'
    expected_sign_here.page_number = '1'
    expected_sign_here.recipient_id = '1'
    expected_sign_here.tab_label = 'SignHereTab'
    expected_sign_here.x_position = '75'
    expected_sign_here.y_position = '572'

    expected_signer_tabs = DocuSign_eSign::Tabs.new({
                                              signHereTabs: [expected_sign_here]
                                            })
    expected_signer.tabs = expected_signer_tabs

    expected_recipients = DocuSign_eSign::Recipients.new(
      signers: [expected_signer]
    )

    expected_envelope = DocuSign_eSign::EnvelopeDefinition.new
    expected_envelope.email_blurb = 'Sample text for email body'
    expected_envelope.email_subject = 'Please Sign'
    expected_envelope.envelope_id_stamping = true
    expected_envelope.brand_id = args[:brands]
    expected_envelope.documents = [expected_document]
    expected_envelope.recipients = expected_recipients
    expected_envelope.status = 'sent'

    envelope = @eg029.send(:make_envelope, args)

    assert_not_nil envelope
    assert_equal expected_envelope, envelope
  end
end
