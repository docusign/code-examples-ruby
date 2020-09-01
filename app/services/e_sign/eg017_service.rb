# frozen_string_literal: true

class ESign::Eg017Service
include ApiCreator
attr_reader :args, :envelope_args

def initialize(request, session, template_id)
  @envelope_args = {
  signer_email: request.params['signerEmail'],
  signer_name: request.params['signerName'],
  cc_email: request.params['ccEmail'],
  cc_name: request.params['ccName'],
  template_id: template_id
  }
  @args = {
  account_id: session['ds_account_id'],
  base_path: session['ds_base_path'],
  access_token: session['ds_access_token'],
  envelope_args: @envelope_args
  }
end

def call
  results = worker
end

private

# ***DS.snippet.0.start
def worker
  ds_ping_url = Rails.application.config.app_url
  ds_return_url = "#{ds_ping_url}/ds_common-return"
  signer_client_id = 1000
  envelope_args = args[:envelope_args]

  # Step 4. Construct the request body
  envelope_definition = make_envelope(envelope_args)

  # Step 5. Call the eSignature REST API
  envelope_api = create_envelope_api(args)
  results = envelope_api.create_envelope args[:account_id], envelope_definition
  envelope_id = results.envelope_id


  # Step 6. Create the View Request
  view_request = make_recipient_view_request(envelope_args[:signer_email], envelope_args[:signer_name], signer_client_id, ds_return_url, ds_ping_url)

  # Call the CreateRecipientView API
  results = create_envelope_api(args).create_recipient_view args[:account_id], envelope_id, view_request

  # Redirect the user to the signing ceremony
  # Don't use an iframe!
  # State can be stored/recovered using the framework's session or a
  # query parameter on the return URL (see the makeRecipientViewRequest method)
  # Redirect to results.url
  results.url
end

def make_envelope(args)
  # Create the envelope definition with the template_id
  envelope_definition = DocuSign_eSign::EnvelopeDefinition.new({
  status: 'sent',
  templateId: args[:template_id]
  })
  # Create the template role elements to connect the signer and cc recipients
  # to the template
  signer = DocuSign_eSign::TemplateRole.new({
  clientUserId: 1000,
  email: args[:signer_email],
  name: args[:signer_name],
  roleName: 'signer'
  })
  # Create a cc template role.
  cc = DocuSign_eSign::TemplateRole.new({
  email: args[:cc_email],
  name: args[:cc_name],
  roleName: 'cc'
  })

  # Step 3. Create Tabs and CustomFields

  # List item
  list1 = DocuSign_eSign::List.new
  list1.value = 'Green'
  list1.document_id = '1'
  list1.page_number = '1'
  list1.tab_label = 'list'

  # Checkboxes
  check1 = DocuSign_eSign::Checkbox.new
  check1.tab_label = 'ckAuthorization'
  check1.selected = 'true'

  check3 = DocuSign_eSign::Checkbox.new
  check3.tab_label = 'ckAgreement'
  check3.selected = 'true'

  radioGroup = DocuSign_eSign::RadioGroup.new
  radioGroup.group_name = 'radio1'
  radio = DocuSign_eSign::Radio.new
  radio.value = 'white'
  radio.selected = 'true'
  radioGroup.radios = [radio]

  text = DocuSign_eSign::Text.new
  text.tab_label = 'text'
  text.value = 'Jabberwocky!'

  # We can also add a new tab (field) to the ones already in the template
  textExtra = DocuSign_eSign::Text.new
  textExtra.document_id = '1'
  textExtra.page_number = '1'
  textExtra.x_position = '280'
  textExtra.y_position = '172'
  textExtra.font = 'helvetica'
  textExtra.font_size = 'size14'
  textExtra.tab_label = 'added text field'
  textExtra.height = '23'
  textExtra.width = '84'
  textExtra.required = 'false'
  textExtra.bold = 'true'
  textExtra.value = args[:signer_name]
  textExtra.locked = 'false'
  textExtra.tab_id = 'name'

  # Pull together the existing and new tabs in a Tabs object
  tabs = DocuSign_eSign::Tabs.new
  tabs.list_tabs = [list1]
  tabs.checkbox_tabs = [check1, check3]
  tabs.radio_group_tabs = [radioGroup]
  tabs.text_tabs = [text, textExtra]
  signer.tabs = tabs

  # Add the TemplateRole objects to the envelope object
  envelope_definition.template_roles = [signer, cc]
  envelope_definition
end


def make_recipient_view_request(signer_email, signer_name, signer_client_id, ds_return_url, ds_ping_url)
  view_request = DocuSign_eSign::RecipientViewRequest.new
  # Set the URL where you want the recipient to go once they are done signing; this
  # should typically be a callback route somewhere in your app. The query parameter
  # is included as an example of how to save/recover state information during the redirect
  # to the DocuSign signing ceremony. It's usually better to use the session mechanism
  # of your web framework. Query parameters can be changed/spoofed very easily
  view_request.return_url = ds_return_url + '?state=123'

  # How has your app authenticated the user? In addition to your app's authentication,
  # you can include authenticate steps from DocuSign; e.g., SMS authentication
  view_request.authentication_method = 'none'

  # Recipient information must match embedded recipient info we used to create the envelope
  view_request.email = signer_email
  view_request.user_name = signer_name
  view_request.client_user_id = signer_client_id

  # DocuSign recommends that you redirect to DocuSign for the signing ceremony. There are
  # multiple ways to save state. To maintain your application's session, use the pingUrl
  # parameter. It causes the DocuSign Signing Ceremony web page (not the DocuSign server)
  # to send pings via AJAX to your app
  view_request.ping_frequency = '600' # seconds
  # NOTE: The pings will only be sent if the pingUrl is an HTTPS address
  view_request.ping_url = ds_ping_url # optional setting

  view_request
end
# ***DS.snippet.0.end
end