# frozen_string_literal: true

class Webforms::Eg002CreateRemoteInstanceService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def create_web_form_template
    templates_api = create_template_api args

    options = DocuSign_eSign::ListTemplatesOptions.new
    options.search_text = args[:template_name]
    web_forms_templates = templates_api.list_templates(args[:account_id], options)

    if web_forms_templates.result_set_size.to_i.positive?
      template_id = web_forms_templates.envelope_templates[0].template_id
    else
      template_req_object = make_web_forms_template
      template = templates_api.create_template(args[:account_id], template_req_object)
      template_id = template.template_id
    end

    template_id
  end

  def list_web_forms
    #ds-snippet-start:WebForms2Step2
    configuration = DocuSign_WebForms::Configuration.new
    api_client = DocuSign_WebForms::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    #ds-snippet-end:WebForms2Step2

    #ds-snippet-start:WebForms2Step3
    webforms_api = DocuSign_WebForms::FormManagementApi.new(api_client)

    options = DocuSign_WebForms::ListFormsOptions.new
    options.search = args[:form_name]

    webforms_api.list_forms(args[:account_id], options)
    #ds-snippet-end:WebForms2Step3
  end

  def create_web_form_instance(form_id)
    configuration = DocuSign_WebForms::Configuration.new

    api_client = DocuSign_WebForms::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")

    #ds-snippet-start:WebForms2Step4
    web_form_values = {
      'PhoneNumber' => '555-555-5555',
      'Yes' => ['Yes'],
      'Company' => 'Tally',
      'JobTitle' => 'Programmer Writer'
    }
    recipient = DocuSign_WebForms::CreateInstanceRequestBodyRecipients.new({
      'roleName' => 'signer',
      'name' => args[:signer_name],
      'email' => args[:signer_email]
    })
    web_form_req_object = DocuSign_WebForms::CreateInstanceRequestBody.new({
      'formValues' => web_form_values,
      'recipients' => [recipient],
      'sendOption' => 'now'
    })
    #ds-snippet-end:WebForms2Step4

    #ds-snippet-start:WebForms2Step5
    webforms_api = DocuSign_WebForms::FormInstanceManagementApi.new(api_client)
    webforms_api.create_instance(args[:account_id], form_id, web_form_req_object)
    #ds-snippet-end:WebForms2Step5
  end

  private

  def make_web_forms_template
    template_name = args[:template_name]
    doc_file = 'World_Wide_Corp_Web_Form.pdf'
    base64_file_content = Base64.encode64(File.binread(File.join('data', doc_file)))

    # Create the document model
    document = DocuSign_eSign::Document.new({
                                              # Create the Docusign document object
                                              'documentBase64' => base64_file_content,
                                              'name' => 'World_Wide_Web_Form', # Can be different from actual file name
                                              'fileExtension' => 'pdf', # Many different document types are accepted
                                              'documentId' => '1' # A label used to reference the doc
                                            })

    # Create the signer recipient model
    # Since these are role definitions, no name/email:
    signer = DocuSign_eSign::Signer.new({
                                          'roleName' => 'signer', 'recipientId' => '1', 'routingOrder' => '1'
                                        })
    # Create fields using absolute positioning
    # Create a sign_here tab (field on the document)
    sign_here = DocuSign_eSign::SignHere.new(
      'documentId' => '1', 'tabLabel' => 'Signature',
      'anchorString' => '/SignHere/', 'anchorUnits' => 'pixels',
      'anchorXOffset' => '0', 'anchorYOffset' => '0'
    )
    check = DocuSign_eSign::Checkbox.new(
      'documentId' => '1', 'tabLabel' => 'Yes',
      'anchorString' => '/SMS/', 'anchorUnits' => 'pixels',
      'anchorXOffset' => '0', 'anchorYOffset' => '0'
    )
    text1 = DocuSign_eSign::Text.new(
      'documentId' => '1', 'tabLabel' => 'FullName',
      'anchorString' => '/FullName/', 'anchorUnits' => 'pixels',
      'anchorXOffset' => '0', 'anchorYOffset' => '0'
    )
    text2 = DocuSign_eSign::Text.new(
      'documentId' => '1', 'tabLabel' => 'PhoneNumber',
      'anchorString' => '/PhoneNumber/', 'anchorUnits' => 'pixels',
      'anchorXOffset' => '0', 'anchorYOffset' => '0'
    )
    text3 = DocuSign_eSign::Text.new(
      'documentId' => '1', 'tabLabel' => 'Company',
      'anchorString' => '/Company/', 'anchorUnits' => 'pixels',
      'anchorXOffset' => '0', 'anchorYOffset' => '0'
    )
    text4 = DocuSign_eSign::Text.new(
      'documentId' => '1', 'tabLabel' => 'JobTitle',
      'anchorString' => '/JobTitle/', 'anchorUnits' => 'pixels',
      'anchorXOffset' => '0', 'anchorYOffset' => '0'
    )
    date_signed = DocuSign_eSign::DateSigned.new(
      'documentId' => '1', 'tabLabel' => 'DateSigned',
      'anchorString' => '/Date/', 'anchorUnits' => 'pixels',
      'anchorXOffset' => '0', 'anchorYOffset' => '0'
    )

    # Add the tabs model to the signer
    # The Tabs object takes arrays of the different field/tab types
    signer.tabs = DocuSign_eSign::Tabs.new(
      'signHereTabs' => [sign_here],
      'checkboxTabs' => [check],
      'textTabs' => [text1, text2, text3, text4],
      'dateSignedTabs' => [date_signed]
    )
    # Create top two objects
    envelope_template_definition = DocuSign_eSign::EnvelopeTemplate.new(
      'description' => 'Example template created via the eSignature API',
      'shared' => 'false'
    )

    # Top object:
    DocuSign_eSign::EnvelopeTemplate.new(
      'documents' => [document],
      'name' => template_name,
      'emailSubject' => 'Please sign this document',
      'envelopeTemplateDefinition' => envelope_template_definition,
      'recipients' => DocuSign_eSign::Recipients.new(
        'signers' => [signer]
      ),
      'status' => 'created'
    )
  end
end
