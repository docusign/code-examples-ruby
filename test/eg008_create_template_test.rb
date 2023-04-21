require 'rubygems'
require 'test/unit'
require_relative './test_helper'
require_relative '../app/services/api_creator'
require_relative '../app/services/e_sign/eg008_create_template_service'

class Eg008CreateTemplateTest < TestHelper
  setup do
    setup_test_data [api_type[:e_sign]]

    args = {
      account_id: @account_id,
      base_path: @base_path,
      access_token: @access_token,
      template_name: @data[:template_name]
    }

    @eg008 = ESign::Eg008CreateTemplateService.new(args)
  end

  test 'should create template if correct data is provided' do
    results = @eg008.worker

    TestData.set_template_id results[:template_id]

    assert_not_nil results
    assert_not_nil results[:template_id]
    assert_not_nil results[:template_name]
    assert_not_empty results[:template_id]
    assert_not_empty results[:template_name]
  end

  test 'should create correct template definition if correct data is provided' do
    expected_document = create_ds_document(@data[:doc_for_template], 'Lorem Ipsum', 'pdf', '1')

    expected_sign_here = DocuSign_eSign::SignHere.new
    expected_sign_here.document_id = '1'
    expected_sign_here.page_number = '1'
    expected_sign_here.x_position = '191'
    expected_sign_here.y_position = '148'

    expected_check1 = DocuSign_eSign::Checkbox.new(
      'documentId' => '1', 'pageNumber' => '1',
      'xPosition' => '75', 'yPosition' => '417', 'tabLabel' => 'ckAuthorization'
    )

    expected_check2 = DocuSign_eSign::Checkbox.new(
      'documentId' => '1', 'pageNumber' => '1',
      'xPosition' => '75', 'yPosition' => '447', 'tabLabel' => 'ckAuthentication'
    )
    expected_check3 = DocuSign_eSign::Checkbox.new(
      'documentId' => '1', 'pageNumber' => '1',
      'xPosition' => '75', 'yPosition' => '478', 'tabLabel' => 'ckAgreement'
    )
    expected_check4 = DocuSign_eSign::Checkbox.new(
      'documentId' => '1', 'pageNumber' => '1',
      'xPosition' => '75', 'yPosition' => '508', 'tabLabel' => 'ckAcknowledgement'
    )

    expected_list1 = DocuSign_eSign::List.new(
      'documentId' => '1',
      'pageNumber' => '1',
      'xPosition' => '142',
      'yPosition' => '291',
      'font' => 'helvetica',
      'fontSize' => 'size14',
      'tabLabel' => 'list',
      'required' => 'false',
      'listItems' => [
        DocuSign_eSign::ListItem.new('text' => 'Red', 'value' => 'red'),
        DocuSign_eSign::ListItem.new('text' => 'Orange', 'value' => 'orange'),
        DocuSign_eSign::ListItem.new('text' => 'Yellow', 'value' => 'yellow'),
        DocuSign_eSign::ListItem.new('text' => 'Green', 'value' => 'green'),
        DocuSign_eSign::ListItem.new('text' => 'Blue', 'value' => 'blue'),
        DocuSign_eSign::ListItem.new('text' => 'Indigo', 'value' => 'indigo'),
        DocuSign_eSign::ListItem.new('text' => 'Violet', 'value' => 'violet')
      ]
    )

    expected_numerical = DocuSign_eSign::Numerical.new(
      'documentId' => '1', 'pageNumber' => '1',
      'xPosition' => '163', 'yPosition' => '260',
      'font' => 'helvetica', 'fontSize' => 'size14', 'validationType' => 'Currency',
      'tabLabel' => 'numericalCurrency', 'width' => '84', 'required' => 'false'
    )
    expected_radio_group =  DocuSign_eSign::RadioGroup.new(
      'documentId' => '1', 'groupName' => 'radio1',
      'radios' => [
        DocuSign_eSign::Radio.new('pageNumber' => '1', 'xPosition' => '142',
                                  'yPosition' => '384', 'value' => 'white',
                                  'required' => 'false'),
        DocuSign_eSign::Radio.new('pageNumber' => '1', 'xPosition' => '74',
                                  'yPosition' => '384', 'value' => 'red',
                                  'required' => 'false'),
        DocuSign_eSign::Radio.new('pageNumber' => '1', 'xPosition' => '220',
                                  'yPosition' => '384', 'value' => 'blue',
                                  'required' => 'false')
      ]
    )

    expected_text = DocuSign_eSign::Text.new(
      'documentId' => '1', 'pageNumber' => '1',
      'xPosition' => '153', 'yPosition' => '230',
      'font' => 'helvetica', 'fontSize' => 'size14',
      'tabLabel' => 'text', 'height' => '23',
      'width' => '84', 'required' => 'false'
    )

    expected_tabs = DocuSign_eSign::Tabs.new
    expected_tabs.sign_here_tabs = [expected_sign_here]
    expected_tabs.checkbox_tabs = [expected_check1, expected_check2, expected_check3, expected_check4]
    expected_tabs.list_tabs = [expected_list1]
    expected_tabs.numerical_tabs = [expected_numerical]
    expected_tabs.radio_group_tabs = [expected_radio_group]
    expected_tabs.text_tabs = [expected_text]

    expected_signer = DocuSign_eSign::Signer.new
    expected_signer.role_name = 'signer'
    expected_signer.recipient_id = '1'
    expected_signer.routing_order = '1'
    expected_signer.tabs = expected_tabs

    expected_cc = DocuSign_eSign::CarbonCopy.new
    expected_cc.role_name = 'cc'
    expected_cc.recipient_id = '2'
    expected_cc.routing_order = '2'

    expected_recipients = DocuSign_eSign::Recipients.new
    expected_recipients.signers = [expected_signer]
    expected_recipients.carbon_copies = [expected_cc]

    expected_template = DocuSign_eSign::EnvelopeTemplate.new
    expected_template.documents = [expected_document]
    expected_template.name = @data[:template_name]
    expected_template.email_subject = 'Please sign this document'
    expected_template.recipients = expected_recipients
    expected_template.status = 'created'

    template = @eg008.send(:make_template_req)

    assert_not_nil template
    assert_equal expected_template, template
  end
end
