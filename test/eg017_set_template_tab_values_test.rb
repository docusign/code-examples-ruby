require 'test/unit'
require_relative './test_helper'
require_relative '../app/services/api_creator'
require_relative '../app/services/e_sign/eg017_set_template_tab_values_service'

class Eg017SetTemplateTabValuesTest < TestHelper
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
      ds_ping_url: @data[:ds_ping_url],
      envelope_args: envelope_args
    }

    @eg017 = ESign::Eg017SetTemplateTabValuesService.new(args)
  end

  test 'should correctly set the tab values of template if correct data is provided' do
    results = @eg017.worker

    assert_not_nil results
    assert_not_empty results
  end

  test 'should create correct envelope definition if correct data is provided' do
    expected_list1 = DocuSign_eSign::List.new
    expected_list1.value = 'Green'
    expected_list1.document_id = '1'
    expected_list1.page_number = '1'
    expected_list1.tab_label = 'list'

    expected_check1 = DocuSign_eSign::Checkbox.new
    expected_check1.tab_label = 'ckAuthorization'
    expected_check1.selected = 'true'

    expected_check3 = DocuSign_eSign::Checkbox.new
    expected_check3.tab_label = 'ckAgreement'
    expected_check3.selected = 'true'

    expected_radio = DocuSign_eSign::Radio.new
    expected_radio.value = 'white'
    expected_radio.selected = 'true'

    expected_radio_group = DocuSign_eSign::RadioGroup.new
    expected_radio_group.group_name = 'radio1'
    expected_radio_group.radios = [expected_radio]

    expected_text = DocuSign_eSign::Text.new
    expected_text.tab_label = 'text'
    expected_text.value = 'Jabberwocky!'

    expected_text_extra = DocuSign_eSign::Text.new
    expected_text_extra.document_id = '1'
    expected_text_extra.page_number = '1'
    expected_text_extra.x_position = '280'
    expected_text_extra.y_position = '172'
    expected_text_extra.font = 'helvetica'
    expected_text_extra.font_size = 'size14'
    expected_text_extra.tab_label = 'added text field'
    expected_text_extra.height = '23'
    expected_text_extra.width = '84'
    expected_text_extra.required = 'false'
    expected_text_extra.bold = 'true'
    expected_text_extra.value = @config['signer_name']
    expected_text_extra.locked = 'false'
    expected_text_extra.tab_id = 'name'

    expected_tabs = DocuSign_eSign::Tabs.new
    expected_tabs.list_tabs = [expected_list1]
    expected_tabs.checkbox_tabs = [expected_check1, expected_check3]
    expected_tabs.radio_group_tabs = [expected_radio_group]
    expected_tabs.text_tabs = [expected_text, expected_text_extra]

    expected_signer = DocuSign_eSign::TemplateRole.new
    expected_signer.client_user_id = 1000
    expected_signer.email = @config['signer_email']
    expected_signer.name = @config['signer_name']
    expected_signer.role_name = 'signer'
    expected_signer.tabs = expected_tabs

    expected_cc = DocuSign_eSign::TemplateRole.new
    expected_cc.email = @data[:cc_email]
    expected_cc.name = @data[:cc_name]
    expected_cc.role_name = 'cc'

    expected_envelope = DocuSign_eSign::EnvelopeDefinition.new
    expected_envelope.template_roles = [expected_signer, expected_cc]
    expected_envelope.status = 'sent'
    expected_envelope.template_id = TestData.get_template_id

    envelope_args = {
      signer_email: @config['signer_email'],
      signer_name: @config['signer_name'],
      cc_email: @data[:cc_email],
      cc_name: @data[:cc_name],
      template_id: TestData.get_template_id
    }

    envelope = @eg017.send(:make_envelope, envelope_args)

    assert_not_nil envelope
    assert_equal expected_envelope, envelope
  end

  test 'should create correct recipient view request if correct data is provided' do
    expected_view_request = DocuSign_eSign::RecipientViewRequest.new
    expected_view_request.return_url = "#{@data[:ds_return_url]}?state=123"
    expected_view_request.authentication_method = 'none'
    expected_view_request.email = @config['signer_email']
    expected_view_request.user_name = @config['signer_name']
    expected_view_request.client_user_id = @data[:signer_client_id]
    expected_view_request.ping_frequency = '600'
    expected_view_request.ping_url = @data[:ds_ping_url]

    view_request = @eg017.send(:make_recipient_view_request, @config['signer_email'], @config['signer_name'], @data[:signer_client_id], @data[:ds_return_url], @data[:ds_ping_url])

    assert_not_nil view_request
    assert_equal expected_view_request, view_request
  end
end
