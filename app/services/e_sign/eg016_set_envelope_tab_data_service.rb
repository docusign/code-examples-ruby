# frozen_string_literal: true

class ESign::Eg016SetEnvelopeTabDataService
  include ApiCreator
  attr_reader :args, :session

  def initialize(request, session)
    @args = {
      # Validation: Delete any non-usual characters
      signer_email: request.params[:signerEmail].gsub(/([^\w\-.+@, ])+/, ''),
      signer_name: request.params[:signerName].gsub(/([^\w\-., ])+/, ''),
      access_token: session['ds_access_token'],
      base_path: session['ds_base_path'],
      account_id: session['ds_account_id']
    }
    @session = session
  end

  def call
    worker
  end

  private

  # ***DS.snippet.0.start
  def worker
    ds_ping_url = Rails.application.config.app_url
    ds_return_url = "#{ds_ping_url}/ds_common-return"
    signer_client_id = 1000
    pdf_filename = 'World_Wide_Corp_salary.docx'

    # Step 4. Construct the request body
    envelope = make_envelope(args[:signer_email], args[:signer_name], signer_client_id, pdf_filename)

    # Step 5. Call the eSignature REST API
    results = create_envelope_api(args).create_envelope args[:account_id], envelope
    envelope_id = results.envelope_id
    # Save for future use within the example launcher
    session[:envelope_id] = envelope_id

    # Step 6. Create the View Request
    view_request = make_recipient_view_request(args[:signer_email], args[:signer_name], signer_client_id, ds_return_url, ds_ping_url)

    # Call the CreateRecipientView API
    results = create_envelope_api(args).create_recipient_view args[:account_id], envelope_id, view_request

    # Step 4. Redirect the user to the embedded signing
    # Don't use an iframe!
    # State can be stored/recovered using the framework's session or a
    # query parameter on the return URL (see the makeRecipientViewRequest method)
    # Redirect to results.url
    results.url
  end

  def make_recipient_view_request(_signer_email, _signer_name, signer_client_id, ds_return_url, ds_ping_url)
    view_request = DocuSign_eSign::RecipientViewRequest.new
    # Set the URL where you want the recipient to go once they are done signing; this
    # should typically be a callback route somewhere in your app. The query parameter
    # is included as an example of how to save/recover state information during the redirect
    # to the DocuSign signing. It's usually better to use the session mechanism
    # of your web framework. Query parameters can be changed/spoofed very easily
    view_request.return_url = ds_return_url + '?state=123'

    # How has your app authenticated the user? In addition to your app's authentication,
    # you can include authenticate steps from DocuSign; e.g., SMS authentication
    view_request.authentication_method = 'none'

    # Recipient information must match embedded recipient info we used to create the envelope
    view_request.email = args[:signer_email]
    view_request.user_name = args[:signer_name]
    view_request.client_user_id = signer_client_id

    # DocuSign recommends that you redirect to DocuSign for the embedded signing. There are
    # multiple ways to save state. To maintain your application's session, use the pingUrl
    # parameter. It causes the DocuSign Signing web page (not the DocuSign server)
    # to send pings via AJAX to your app
    view_request.ping_frequency = '600' # seconds
    # NOTE: The pings will only be sent if the pingUrl is an HTTPS address
    view_request.ping_url = ds_ping_url # optional setting

    view_request
  end

  def make_envelope(_signer_email, _signer_name, signer_client_id, pdf_filename)
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
    signer1 = DocuSign_eSign::Signer.new ({
      email: args[:signer_email], name: args[:signer_name],
      clientUserId: signer_client_id, recipientId: 1
    })

    # Step 3. Create Tabs and CustomFields
    salary = '$123,000'

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
    text_legal.value = args[:signer_name]
    text_legal.locked = 'false'
    text_legal.tab_id = 'legal_name'
    text_legal.tab_label = 'Legal name'

    text_familiar = DocuSign_eSign::Text.new
    text_familiar.anchor_string = '/familiar/'
    text_familiar.anchor_units = 'pixels'
    text_familiar.anchor_y_offset = '-9'
    text_familiar.anchor_y_offset = '5'
    text_familiar.font = 'Helvetica'
    text_familiar.font_size = 'size11'
    text_familiar.bold = 'true'
    text_familiar.value = args[:signer_name]
    text_familiar.locked = 'false'
    text_familiar.tab_id = 'familiar_name'
    text_familiar.tab_label = 'Familiar name'

    text_salary = DocuSign_eSign::Text.new
    text_salary.anchor_string = '/salary/'
    text_salary.anchor_units = 'pixels'
    text_salary.anchor_y_offset = '-9'
    text_salary.anchor_y_offset = '5'
    text_salary.font = 'Helvetica'
    text_salary.font_size = 'size11'
    text_salary.bold = 'true'
    text_salary.value = salary
    text_salary.locked = 'true'
    text_salary.tab_id = 'salary'
    text_salary.tab_label = 'Salary'

    # Tabs are set per recipient / signer
    tabs = DocuSign_eSign::Tabs.new
    tabs.sign_here_tabs = [sign_here1]
    tabs.text_tabs = [text_legal, text_familiar, text_salary]

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
  # ***DS.snippet.0.end
end
