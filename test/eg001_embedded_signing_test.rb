require 'rubygems'
require 'test/unit'
require 'json'
require_relative 'test_helper'
require_relative '../app/services/api_creator'
require_relative '../app/services/eg001_embedded_signing_service'

class Eg001EmbeddedSigningTest < TestHelper
  setup do
    setup_test_data

    args = {
      account_id: @account_id,
      base_path: @base_path,
      access_token: @access_token,
      signer_email: @config['signer_email'],
      signer_name: @config['signer_name'],
      ds_ping_url: @data[:ds_ping_url],
      signer_client_id: @data[:signer_client_id],
      pdf_filename: @data[:doc_pdf]
    }

    @eg001_embedded_signing_service = Eg001EmbeddedSigningService.new(args)
  end

  test 'should create and send an envelope if correct data is provided' do
    redirect_url = @eg001_embedded_signing_service.worker

    assert_not_nil redirect_url
    assert_not_empty redirect_url
  end

  test 'should create correct envelope definition if correct data is provided' do
    expected_document = create_ds_document(@data[:doc_pdf], 'Lorem Ipsum', 'pdf', '1')

    expected_sign_here_tab = DocuSign_eSign::SignHere.new
    expected_sign_here_tab.anchor_string = '/sn1/'
    expected_sign_here_tab.anchor_units = 'pixels'
    expected_sign_here_tab.anchor_x_offset = '20'
    expected_sign_here_tab.anchor_y_offset = '10'

    expected_tabs = DocuSign_eSign::Tabs.new
    expected_tabs.sign_here_tabs = [expected_sign_here_tab]

    expected_signer = DocuSign_eSign::Signer.new
    expected_signer.email = @config['signer_email']
    expected_signer.name = @config['signer_name']
    expected_signer.client_user_id = @data[:signer_client_id]
    expected_signer.recipient_id = 1

    expected_signer.tabs = expected_tabs

    expected_recipient = DocuSign_eSign::Recipients.new
    expected_recipient.signers = [expected_signer]

    expected_envelope = DocuSign_eSign::EnvelopeDefinition.new
    expected_envelope.email_subject = 'Please sign this document sent from Ruby SDK'
    expected_envelope.documents = [expected_document]
    expected_envelope.recipients = expected_recipient
    expected_envelope.status = 'sent'

    envelope = @eg001_embedded_signing_service.send(:make_envelope, @data[:signer_client_id], @data[:doc_pdf], @config['signer_email'], @config['signer_name'])

    assert_not_nil envelope
    assert_equal expected_envelope, envelope
  end

  test 'should create correct recipient view if correct data is provided' do
    expected_view_request = DocuSign_eSign::RecipientViewRequest.new
    expected_view_request.return_url = "#{@data[:ds_return_url]}?state=123"
    expected_view_request.authentication_method = 'none'
    expected_view_request.email = @config['signer_email']
    expected_view_request.user_name = @config['signer_name']
    expected_view_request.client_user_id = @data[:signer_client_id]
    expected_view_request.ping_frequency = '600'
    expected_view_request.ping_url = @data[:ds_ping_url]

    recipient_view = @eg001_embedded_signing_service.send(:make_recipient_view_request, @data[:signer_client_id], @data[:ds_return_url], @data[:ds_ping_url], @config['signer_email'], @config['signer_name'])

    assert_not_nil recipient_view
    assert_equal expected_view_request, recipient_view
  end
end
