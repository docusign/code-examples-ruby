require 'test/unit'
require_relative './test_helper'
require_relative '../app/services/api_creator'
require_relative '../app/services/e_sign/eg009_use_template_service'

class Eg009UseTemplateTest < TestHelper
  setup do
    setup_test_data

    envelope_args = {
      signer_email: @config['signer_email'],
      signer_name: @config['signer_name'],
      cc_email: @data[:cc_email],
      cc_name: @data[:cc_name],
      template_id: TestData.get_template_id
    }
    args = {
      account_id: @account_id,
      base_path: @base_path,
      access_token: @access_token,
      envelope_args: envelope_args
    }

    @eg009 = ESign::Eg009UseTemplateService.new(args)
  end

  test 'should create the envelope with template if correct data is provided' do
    results = @eg009.worker

    assert_not_nil results
    assert_not_nil results[:envelope_id]
    assert_not_empty results[:envelope_id]
  end

  test 'should create correct envelope definition if correct data is provided' do
    expected_check1 = DocuSign_eSign::Checkbox.new
    expected_check1.tab_label = 'ckAuthorization'
    expected_check1.selected = true

    expected_check3 = DocuSign_eSign::Checkbox.new
    expected_check3.tab_label = 'ckAgreement'
    expected_check3.selected = true

    expected_text = DocuSign_eSign::Text.new
    expected_text.tab_label = 'text'
    expected_text.value = 'Jabberwocky!'

    expected_tabs = DocuSign_eSign::Tabs.new
    expected_tabs.checkbox_tabs = [expected_check1, expected_check3]
    expected_tabs.text_tabs = [expected_text]

    expected_signer = DocuSign_eSign::TemplateRole.new
    expected_signer.email = @config['signer_email']
    expected_signer.name = @config['signer_name']
    expected_signer.role_name = 'signer'
    expected_signer.tabs = expected_tabs

    expected_cc = DocuSign_eSign::TemplateRole.new
    expected_cc.email = @data[:cc_email]
    expected_cc.name = @data[:cc_name]
    expected_cc.role_name = 'cc'

    expected_envelope = DocuSign_eSign::EnvelopeDefinition.new
    expected_envelope.status = 'sent'
    expected_envelope.template_id = TestData.get_template_id
    expected_envelope.template_roles = [expected_signer, expected_cc]

    envelope_args = {
      signer_email: @config['signer_email'],
      signer_name: @config['signer_name'],
      cc_email: @data[:cc_email],
      cc_name: @data[:cc_name],
      template_id: TestData.get_template_id
    }

    envelope = @eg009.send(:make_envelope, envelope_args)

    assert_not_nil envelope
    assert_equal expected_envelope, envelope
  end
end
