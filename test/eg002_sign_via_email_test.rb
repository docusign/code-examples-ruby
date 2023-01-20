require 'rubygems'
require 'test/unit'
require_relative './test_helper'
require_relative '../app/services/api_creator'
require_relative '../app/services/e_sign/eg002_signing_via_email_service'

class Eg002SignViaEmailTest < TestHelper
  setup do
    setup_test_data

    envelope_args = {
      signer_email: @config['signer_email'],
      signer_name: @config['signer_name'],
      cc_email: @data[:cc_email],
      cc_name: @data[:cc_name],
      status: 'sent',
      doc_docx: @data[:doc_docx],
      doc_pdf: @data[:doc_pdf]
    }
    @args = {
      account_id: @account_id,
      base_path: @base_path,
      access_token: @access_token,
      envelope_args: envelope_args
    }

    @eg002 = ESign::Eg002SigningViaEmailService.new(@args)
  end

  test 'should create and send an envelope if correct data is provided' do
    results = @eg002.worker

    assert_not_nil results
    assert_not_empty results
    assert_not_nil results['envelope_id']
    assert_not_empty results['envelope_id']
  end

  test 'should create correct envelope definition if correct data is provided' do
    expected_html_document = create_ds_document(expected_html_doc, 'Order acknowledgement', 'html', '1')
    expected_docx_document = create_ds_document(@data[:doc_docx], 'Battle Plan', 'docx', '2')
    expected_pdf_document = create_ds_document(@data[:doc_pdf], 'Lorem Ipsum', 'pdf', '3')

    expected_sign_here_tab1 = DocuSign_eSign::SignHere.new
    expected_sign_here_tab1.anchor_string = '**signature_1**'
    expected_sign_here_tab1.anchor_units = 'pixels'
    expected_sign_here_tab1.anchor_x_offset = '20'
    expected_sign_here_tab1.anchor_y_offset = '10'

    expected_sign_here_tab2 = DocuSign_eSign::SignHere.new
    expected_sign_here_tab2.anchor_string = '/sn1/'
    expected_sign_here_tab2.anchor_units = 'pixels'
    expected_sign_here_tab2.anchor_x_offset = '20'
    expected_sign_here_tab2.anchor_y_offset = '10'

    expected_tabs = DocuSign_eSign::Tabs.new
    expected_tabs.sign_here_tabs = [expected_sign_here_tab1, expected_sign_here_tab2]

    expected_signer = DocuSign_eSign::Signer.new
    expected_signer.email = @config['signer_email']
    expected_signer.name = @config['signer_name']
    expected_signer.recipient_id = '1'
    expected_signer.routing_order = '1'

    expected_signer.tabs = expected_tabs

    expected_cc = DocuSign_eSign::CarbonCopy.new
    expected_cc.email = @data[:cc_email]
    expected_cc.name = @data[:cc_name]
    expected_cc.routing_order = '2'
    expected_cc.recipient_id = '2'

    expected_recipient = DocuSign_eSign::Recipients.new
    expected_recipient.signers = [expected_signer]
    expected_recipient.carbon_copies = [expected_cc]

    expected_envelope = DocuSign_eSign::EnvelopeDefinition.new
    expected_envelope.email_subject = 'Please sign this document set'
    expected_envelope.documents = [expected_html_document, expected_docx_document, expected_pdf_document]
    expected_envelope.recipients = expected_recipient
    expected_envelope.status = 'sent'

    envelope_args = {
      signer_email: @config['signer_email'],
      signer_name: @config['signer_name'],
      cc_email: @data[:cc_email],
      cc_name: @data[:cc_name],
      status: 'sent',
      doc_docx: @data[:doc_docx],
      doc_pdf: @data[:doc_pdf]
    }

    envelope = @eg002.send(:make_envelope, envelope_args)

    assert_not_nil envelope
    assert_equal expected_envelope, envelope
  end

  test 'should create correct html document if correct data is provided' do
    envelope_args = {
      signer_email: @config['signer_email'],
      signer_name: @config['signer_name'],
      cc_email: @data[:cc_email],
      cc_name: @data[:cc_name]
    }

    html_document = @eg002.send(:create_document1, envelope_args)

    assert_not_nil html_document
    assert_not_empty html_document
    assert_equal expected_html_doc, html_document
  end

  def expected_html_doc
    "
    <!DOCTYPE html>
    <html>
        <head>
          <meta charset=\"UTF-8\">
        </head>
        <body style=\"font-family:sans-serif;margin-left:2em;\">
        <h1 style=\"font-family: 'Trebuchet MS', Helvetica, sans-serif;
color: darkblue;margin-bottom: 0;\">World Wide Corp</h1>
        <h2 style=\"font-family: 'Trebuchet MS', Helvetica, sans-serif;
margin-top: 0px;margin-bottom: 3.5em;font-size: 1em;
color: darkblue;\">Order Processing Division</h2>
        <h4>Ordered by #{@config['signer_name']}</h4>
        <p style=\"margin-top:0em; margin-bottom:0em;\">Email: #{@config['signer_email']}</p>
        <p style=\"margin-top:0em; margin-bottom:0em;\">Copy to: #{@data[:cc_name]}, #{@data[:cc_email]}</p>
        <p style=\"margin-top:3em;\">
  Candy bonbon pastry jujubes lollipop wafer biscuit biscuit. Topping brownie sesame snaps sweet roll pie. Croissant danish biscuit soufflé caramels jujubes jelly. Dragée danish caramels lemon drops dragée. Gummi bears cupcake biscuit tiramisu sugar plum pastry. Dragée gummies applicake pudding liquorice. Donut jujubes oat cake jelly-o. Dessert bear claw chocolate cake gummies lollipop sugar plum ice cream gummies cheesecake.
        </p>
        <!-- Note the anchor tag for the signature field is in white. -->
        <h3 style=\"margin-top:3em;\">Agreed: <span style=\"color:white;\">**signature_1**/</span></h3>
        </body>
    </html>"
  end
end

