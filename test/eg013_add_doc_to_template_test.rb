require 'rubygems'
require 'test/unit'
require_relative './test_helper'
require_relative '../app/services/api_creator'
require_relative '../app/services/e_sign/eg013_add_doc_to_template_service'

class Eg013AddDocToTemplateTest < TestHelper
  setup do
    setup_test_data [api_type[:e_sign]]

    envelope_args = {
      signer_email: @config['signer_email'],
      signer_name: @config['signer_name'],
      cc_email: @data[:cc_email],
      cc_name: @data[:cc_name],
      item: @data[:item],
      quantity: @data[:quantity],
      signer_client_id: @data[:signer_client_id],
      template_id: TestData.get_template_id,
      ds_return_url: @data[:ds_return_url]
    }
    args = {
      account_id: @account_id,
      base_path: @base_path,
      access_token: @access_token,
      envelope_args: envelope_args
    }

    @eg013 = ESign::Eg013AddDocToTemplateService.new(args)
  end

  test 'should correctly add document to a template if correct data is provided' do
    results = @eg013.worker

    assert_not_nil results
    assert_not_nil results[:envelope_id]
    assert_not_empty results[:envelope_id]
    assert_not_nil results[:redirect_url]
    assert_not_empty results[:redirect_url]
  end

  test 'should create the correct envelope definition if correct data is provided' do
    expected_signer1 = DocuSign_eSign::Signer.new
    expected_signer1.email = @config['signer_email']
    expected_signer1.name = @config['signer_name']
    expected_signer1.role_name = 'signer'
    expected_signer1.recipient_id = '1'
    expected_signer1.client_user_id = @data[:signer_client_id]

    expected_cc1 = DocuSign_eSign::CarbonCopy.new
    expected_cc1.email = @data[:cc_email]
    expected_cc1.name = @data[:cc_name]
    expected_cc1.role_name = 'cc'
    expected_cc1.recipient_id = '2'

    expected_recipients_server_template = DocuSign_eSign::Recipients.new
    expected_recipients_server_template.carbon_copies = [expected_cc1]
    expected_recipients_server_template.signers = [expected_signer1]

    expected_server_template = DocuSign_eSign::ServerTemplate.new
    expected_server_template.sequence = '1'
    expected_server_template.template_id = TestData.get_template_id

    expected_inline_template1 = DocuSign_eSign::InlineTemplate.new
    expected_inline_template1.sequence = '2'
    expected_inline_template1.recipients = expected_recipients_server_template

    expected_comp_template1 = DocuSign_eSign::CompositeTemplate.new
    expected_comp_template1.server_templates = [expected_server_template]
    expected_comp_template1.inline_templates = [expected_inline_template1]

    expected_sign_here1 = DocuSign_eSign::SignHere.new
    expected_sign_here1.anchor_string = '**signature_1**'
    expected_sign_here1.anchor_y_offset = '10'
    expected_sign_here1.anchor_units = 'pixels'
    expected_sign_here1.anchor_x_offset = '20'

    expected_signer1_tabs = DocuSign_eSign::Tabs.new
    expected_signer1_tabs.sign_here_tabs = [expected_sign_here1]

    expected_signer1_added_doc = DocuSign_eSign::Signer.new
    expected_signer1_added_doc.email = @config['signer_email']
    expected_signer1_added_doc.name = @config['signer_name']
    expected_signer1_added_doc.role_name = 'signer'
    expected_signer1_added_doc.recipient_id = '1'
    expected_signer1_added_doc.client_user_id = @data[:signer_client_id]
    expected_signer1_added_doc.tabs = expected_signer1_tabs

    expected_recipients_added_doc = DocuSign_eSign::Recipients.new
    expected_recipients_added_doc.carbon_copies = [expected_cc1]
    expected_recipients_added_doc.signers = [expected_signer1_added_doc]

    expected_doc = create_ds_document(expected_html_doc, 'Appendix 1--Sales order', 'html', '1')

    expected_inline_template2 = DocuSign_eSign::InlineTemplate.new
    expected_inline_template2.sequence = '1'
    expected_inline_template2.recipients = expected_recipients_added_doc

    expected_comp_template2 = DocuSign_eSign::CompositeTemplate.new
    expected_comp_template2.composite_template_id = '2'
    expected_comp_template2.inline_templates = [expected_inline_template2]
    expected_comp_template2.document = expected_doc

    expected_envelope = DocuSign_eSign::EnvelopeDefinition.new
    expected_envelope.status = 'sent'
    expected_envelope.composite_templates = [expected_comp_template1, expected_comp_template2]

    envelope_args = {
      signer_email: @config['signer_email'],
      signer_name: @config['signer_name'],
      cc_email: @data[:cc_email],
      cc_name: @data[:cc_name],
      item: @data[:item],
      quantity: @data[:quantity],
      signer_client_id: @data[:signer_client_id],
      template_id: TestData.get_template_id,
      ds_return_url: @data[:ds_return_url]
    }

    envelope = @eg013.send(:make_envelope, envelope_args)

    assert_not_nil envelope
    assert_equal expected_envelope, envelope
  end

  test 'should return correct HTML document if correct data is provided' do
    envelope_args = {
      signer_email: @config['signer_email'],
      signer_name: @config['signer_name'],
      cc_email: @data[:cc_email],
      cc_name: @data[:cc_name],
      item: @data[:item],
      quantity: @data[:quantity]
    }

    html_doc = @eg013.send(:create_document1, envelope_args)

    assert_not_nil html_doc
    assert_not_empty html_doc
    assert_equal expected_html_doc, html_doc
  end

  def expected_html_doc
    <<~HEREDOC
          <!DOCTYPE html>
          <html>
              <head>
                <meta charset="UTF-8">
              </head>
              <body style="font-family:sans-serif;margin-left:2em;">
              <h1 style="font-family: 'Trebuchet MS', Helvetica, sans-serif;
      color: darkblue;margin-bottom: 0;">World Wide Corp</h1>
              <h2 style="font-family: 'Trebuchet MS', Helvetica, sans-serif;
      margin-top: 0px;margin-bottom: 3.5em;font-size: 1em;
      color: darkblue;">Order Processing Division</h2>
              <h4>Ordered by #{@config['signer_name']}</h4>
              <p style="margin-top:0em; margin-bottom:0em;">Email: #{@config['signer_email']}</p>
              <p style="margin-top:0em; margin-bottom:0em;">Copy to: #{@data[:cc_name]}, #{@data[:cc_email]}</p>
              <p style="margin-top:3em; margin-bottom:0em;">Item: <b>#{@data[:item]}</b>, quantity: <b>#{@data[:quantity]}</b> at market price.</p>
              <p style="margin-top:3em;">
        Candy bonbon pastry jujubes lollipop wafer biscuit biscuit. Topping brownie sesame snaps sweet roll pie. Croissant danish biscuit soufflé caramels jujubes jelly. Dragée danish caramels lemon drops dragée. Gummi bears cupcake biscuit tiramisu sugar plum pastry. Dragée gummies applicake pudding liquorice. Donut jujubes oat cake jelly-o. Dessert bear claw chocolate cake gummies lollipop sugar plum ice cream gummies cheesecake.
              </p>
              <!-- Note the anchor tag for the signature field is in white. -->
              <h3 style="margin-top:3em;">Agreed: <span style="color:white;">**signature_1**/</span></h3>
              </body>
          </html>
    HEREDOC
  end
end
