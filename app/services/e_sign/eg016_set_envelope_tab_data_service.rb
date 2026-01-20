# frozen_string_literal: true

class ESign::Eg016SetEnvelopeTabDataService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    ds_ping_url = Rails.application.config.app_url
    ds_return_url = "#{ds_ping_url}/ds_common-return"
    signer_client_id = 1000
    pdf_filename = 'World_Wide_Corp_salary.docx'

    # Construct the request body
    envelope = make_envelope(args[:signer_email], args[:signer_name], signer_client_id, pdf_filename)

    # Call the eSignature REST API
    #ds-snippet-start:eSign16Step4
    results, _status, headers = create_envelope_api(args).create_envelope_with_http_info args[:account_id], envelope

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end

    envelope_id = results.envelope_id
    #ds-snippet-end:eSign16Step4

    # Create the View Request
    #ds-snippet-start:eSign16Step5
    view_request = make_recipient_view_request(args[:signer_email], args[:signer_name], signer_client_id, ds_return_url, ds_ping_url)
    #ds-snippet-end:eSign16Step5

    # Call the CreateRecipientView API
    results, _status, headers = create_envelope_api(args).create_recipient_view_with_http_info args[:account_id], envelope_id, view_request

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end

    # Redirect the user to the embedded signing
    # Don't use an iframe!
    # State can be stored/recovered using the framework's session or a
    # query parameter on the return URL (see the makeRecipientViewRequest method)
    # Redirect to results.url
    { url: results.url, envelope_id: envelope_id }
  end

  def make_recipient_view_request(signer_email, signer_name, signer_client_id, ds_return_url, ds_ping_url)
    view_request = DocuSign_eSign::RecipientViewRequest.new
    # Set the URL where you want the recipient to go once they are done signing; this
    # should typically be a callback route somewhere in your app. The query parameter
    # is included as an example of how to save/recover state information during the redirect
    # to the Docusign signing. It's usually better to use the session mechanism
    # of your web framework. Query parameters can be changed/spoofed very easily
    view_request.return_url = "#{ds_return_url}?state=123"

    # How has your app authenticated the user? In addition to your app's authentication,
    # you can include authenticate steps from Docusign; e.g., SMS authentication
    view_request.authentication_method = 'none'

    # Recipient information must match embedded recipient info we used to create the envelope
    view_request.email = signer_email
    view_request.user_name = signer_name
    view_request.client_user_id = signer_client_id

    # Docusign recommends that you redirect to Docusign for the embedded signing. There are
    # multiple ways to save state. To maintain your application's session, use the pingUrl
    # parameter. It causes the Docusign Signing web page (not the Docusign server)
    # to send pings via AJAX to your app
    view_request.ping_frequency = '600' # seconds
    # NOTE: The pings will only be sent if the pingUrl is an HTTPS address
    view_request.ping_url = ds_ping_url # optional setting

    view_request
  end

  #ds-snippet-start:eSign16Step3
  def make_envelope(signer_email, signer_name, signer_client_id, pdf_filename)
    envelope_definition = DocuSign_eSign::EnvelopeDefinition.new
    envelope_definition.email_subject = 'Please sign this document sent from Ruby SDK'

    doc1 = DocuSign_eSign::Document.new
    doc1.document_base64 = Base64.encode64(File.binread(File.join('data', pdf_filename)))
    doc1.name = 'Lorem Ipsum'
    doc1.file_extension = 'docx'
    doc1.document_id = '1'

    # The order in the docs array determines the order in the envelope
    envelope_definition.documents = [doc1]
    # Create a signer recipient to sign the document, identified by name and email
    # We're setting the parameters via the object creation
    signer1 = DocuSign_eSign::Signer.new({
                                           email: signer_email, name: signer_name,
                                           clientUserId: signer_client_id, recipientId: 1
                                         })

    # Create Tabs and CustomFields

    sign_here1 = DocuSign_eSign::SignHere.new
    sign_here1.anchor_string = '/sn1/'
    sign_here1.anchor_units = 'pixels'
    sign_here1.anchor_x_offset = '20'
    sign_here1.anchor_y_offset = '10'

    text_legal = DocuSign_eSign::Text.new
    text_legal.anchor_string = '/legal/'
    text_legal.anchor_units = 'pixels'
    text_legal.anchor_y_offset = '-9'
    text_legal.anchor_x_offset = '5'
    text_legal.font = 'Helvetica'
    text_legal.font_size = 'size11'
    text_legal.bold = 'true'
    text_legal.value = signer_name
    text_legal.locked = 'false'
    text_legal.tab_id = 'legal_name'
    text_legal.tab_label = 'Legal name'

    text_familiar = DocuSign_eSign::Text.new
    text_familiar.anchor_string = '/familiar/'
    text_familiar.anchor_units = 'pixels'
    text_familiar.anchor_y_offset = '-9'
    text_familiar.anchor_x_offset = '5'
    text_familiar.font = 'Helvetica'
    text_familiar.font_size = 'size11'
    text_familiar.bold = 'true'
    text_familiar.value = signer_name
    text_familiar.locked = 'false'
    text_familiar.tab_id = 'familiar_name'
    text_familiar.tab_label = 'Familiar name'

    locale_policy_tab = DocuSign_eSign::LocalePolicyTab.new
    locale_policy_tab.culture_name = 'en-US'
    locale_policy_tab.currency_code = 'usd'
    locale_policy_tab.currency_positive_format = 'csym_1_comma_234_comma_567_period_89'
    locale_policy_tab.currency_negative_format = 'minus_csym_1_comma_234_comma_567_period_89'
    locale_policy_tab.use_long_currency_format = 'true'

    numerical_salary = DocuSign_eSign::Numerical.new
    numerical_salary.page_number = '1'
    numerical_salary.document_id = '1'
    numerical_salary.x_position = '210'
    numerical_salary.y_position = '235'
    numerical_salary.height = '20'
    numerical_salary.width = '70'
    numerical_salary.min_numerical_value = '0'
    numerical_salary.max_numerical_value = '1000000'
    numerical_salary.validation_type = 'Currency'
    numerical_salary.font = 'Helvetica'
    numerical_salary.font_size = 'size11'
    numerical_salary.bold = 'true'
    numerical_salary.tab_id = 'salary'
    numerical_salary.tab_label = 'Salary'
    numerical_salary.numerical_value = '123000'
    numerical_salary.locale_policy = locale_policy_tab

    salary_custom_field = DocuSign_eSign::TextCustomField.new
    salary_custom_field.name = 'salary'
    salary_custom_field.required = 'false'
    salary_custom_field.show = 'true'
    salary_custom_field.value = '123000'

    cf = DocuSign_eSign::CustomFields.new
    cf.text_custom_fields = [salary_custom_field]
    envelope_definition.custom_fields = cf

    # Tabs are set per recipient / signer
    tabs = DocuSign_eSign::Tabs.new
    tabs.sign_here_tabs = [sign_here1]
    tabs.text_tabs = [text_legal, text_familiar]
    tabs.numerical_tabs = [numerical_salary]

    signer1.tabs = tabs
    # Add the recipients to the envelope object
    recipients = DocuSign_eSign::Recipients.new
    recipients.signers = [signer1]

    envelope_definition.recipients = recipients
    # Request that the envelope be sent by setting status to "sent".
    # To request that the envelope be created as a draft, set status to "created"
    envelope_definition.status = 'sent'
    envelope_definition
  end
  #ds-snippet-end:eSign16Step3
end
