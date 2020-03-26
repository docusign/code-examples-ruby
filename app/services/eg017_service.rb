# frozen_string_literal: true

class Eg017Service
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
    envelope_args = args[:envelope_args]
    # 1. Create the envelope request object
    envelope_definition = make_envelope(envelope_args)
    # 2. call Envelopes::create API method
    # Exceptions will be caught by the calling function
    envelope_api = create_envelope_api(args)
    results = envelope_api.create_envelope args[:account_id], envelope_definition
    envelope_id = results.envelope_id
    { envelope_id: envelope_id }
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
    # Set values for the fields in the template

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
  # ***DS.snippet.0.end
end