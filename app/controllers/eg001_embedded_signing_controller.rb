class Eg001EmbeddedSigningController < EgController
  skip_before_action :verify_authenticity_token
  def eg_name
    'eg001'
  end
  def get_file_name
    File.basename __FILE__
  end

  def create
    minimum_buffer_min = 10
    token_ok = check_token(minimum_buffer_min)
    if !token_ok
      flash[:messages] = 'Sorry, you need to re-authenticate.'
      # We could store the parameters of the requested operation
      # so it could be restarted automatically.
      # But since it should be rare to have a token issue here,
      # we'll make the user re-enter the form data after
      # authentication.
      redirect_to '/ds/mustAuthenticate'
    end

    # Validation: Delete any non-usual characters
    signer_email = request.params[:signerEmail].gsub(/([^\w \-\@\.\,])+/, '')
    signer_name =  request.params[:signerName].gsub(/([^\w \-\@\.\,])+/, '')
    access_token = session['ds_access_token']
    base_url = session['ds_base_path']
    account_id = session['ds_account_id']

    redirect_url = worker access_token, base_url, account_id, signer_email, signer_name
    redirect_to redirect_url
  end

  # ***DS.snippet.0.start
  def worker (access_token, base_url, account_id, signer_email, signer_name)
    ds_ping_url = 'http://localhost:3000/'
    ds_return_url = "#{Rails.application.config.app_url}/ds_common-return"
    signer_client_id = 1000
    pdf_filename = 'World_Wide_Corp_lorem.pdf'
  
    # Step 1. Create the envelope definition
    envelope = make_envelope(signer_email, signer_name, signer_client_id, pdf_filename);

    # Step 2. Call DocuSign to create the envelope
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = base_url
    api_client = DocuSign_eSign::ApiClient.new configuration
    api_client.default_headers['Authorization'] = 'Bearer ' + access_token
    envelope_api = DocuSign_eSign::EnvelopesApi.new api_client

    results = envelope_api.create_envelope account_id, envelope
    envelope_id = results.envelope_id
    # Save for future use within the example launcher
    session[:envelope_id] = envelope_id

    # Step 3. create the recipient view, the Signing Ceremony
    view_request = make_recipient_view_request(
                    signer_email, signer_name, signer_client_id, ds_return_url, ds_ping_url)

    # call the CreateRecipientView API
    results = envelope_api.create_recipient_view account_id, envelope_id, view_request

    # Step 4. Redirect the user to the Signing Ceremony
    # Don't use an iFrame!
    # State can be stored/recovered using the framework's session or a
    # query parameter on the returnUrl (see the makeRecipientViewRequest method)
    # redirect to results.url
    results.url
  end

  def make_recipient_view_request(signer_email, signer_name, signer_client_id, 
                                  ds_return_url, ds_ping_url)
    view_request = DocuSign_eSign::RecipientViewRequest.new
    # Set the url where you want the recipient to go once they are done signing
    # should typically be a callback route somewhere in your app.
    # The query parameter is included as an example of how
    # to save/recover state information during the redirect to
    # the DocuSign signing ceremony. It's usually better to use
    # the session mechanism of your web framework. Query parameters
    # can be changed/spoofed very easily.
    view_request.return_url = ds_return_url + '?state=123'

    # How has your app authenticated the user? In addition to your app's
    # authentication, you can include authenticate steps from DocuSign.
    # Eg, SMS authentication
    view_request.authentication_method = 'none'

    # Recipient information must match embedded recipient info
    # we used to create the envelope.
    view_request.email = signer_email
    view_request.user_name = signer_name
    view_request.client_user_id = signer_client_id

    # DocuSign recommends that you redirect to DocuSign for the
    # Signing Ceremony. There are multiple ways to save state.
    # To maintain your application's session, use the pingUrl
    # parameter. It causes the DocuSign Signing Ceremony web page
    # (not the DocuSign server) to send pings via AJAX to your
    # app,
    view_request.ping_frequency = '600' # seconds
    # NOTE: The pings will only be sent if the pingUrl is an https address
    view_request.ping_url = ds_ping_url # optional setting

    view_request
  end

  def make_envelope(signer_email, signer_name, signer_client_id, pdf_filename)
    envelope_definition = DocuSign_eSign::EnvelopeDefinition.new
    envelope_definition.email_subject = 'Please sign this document sent from Ruby SDK'

    doc1 = DocuSign_eSign::Document.new
    doc1.document_base64 = Base64.encode64(File.binread(File.join('data', pdf_filename)))
    doc1.name = 'pdf'
    doc1.file_extension = 'Lorem Ipsum'
    doc1.document_id = '1'

    # The order in the docs array determines the order in the envelope
    envelope_definition.documents = [doc1]
    # create a signer recipient to sign the document, identified by name and email
    # We're setting the parameters via the object creation
    signer1 = DocuSign_eSign::Signer.new ({
      email: signer_email, name: signer_name,
      clientUserId: signer_client_id, recipientId: 1
    })
    # The DocuSign platform searches throughout your envelope's
    # documents for matching anchor strings. So the
    # sign_here_2 tab will be used in both document 2 and 3 since they
    # use the same anchor string for their "signer 1" tabs.
    sign_here1 = DocuSign_eSign::SignHere.new
    sign_here1.anchor_string = '/sn1/'
    sign_here1.anchor_units = 'pixels'
    sign_here1.anchor_x_offset = '20'
    sign_here1.anchor_y_offset = '10'
    # Tabs are set per recipient / signer
    tabs = DocuSign_eSign::Tabs.new
    tabs.sign_here_tabs = [sign_here1]
    signer1.tabs = tabs
    # Add the recipients to the envelope object
    recipients = DocuSign_eSign::Recipients.new
    recipients.signers = [signer1]

    envelope_definition.recipients = recipients
    # Request that the envelope be sent by setting |status| to "sent".
    # To request that the envelope be created as a draft, set to "created"
    envelope_definition.status = 'sent'
    envelope_definition
  end
  # ***DS.snippet.0.end
end
