# frozen_string_literal: true

class Webforms::Eg001CreateInstanceService
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
    configuration = DocuSign_WebForms::Configuration.new

    api_client = DocuSign_WebForms::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")

    webforms_api = DocuSign_WebForms::FormManagementApi.new(api_client)

    options = DocuSign_WebForms::ListFormsOptions.new
    options.search = args[:form_name]

    webforms_api.list_forms(args[:account_id], options)
  end

  def create_web_form_instance(form_id)
    configuration = DocuSign_WebForms::Configuration.new

    api_client = DocuSign_WebForms::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")

    webforms_api = DocuSign_WebForms::FormInstanceManagementApi.new(api_client)

    web_form_values = {
      'PhoneNumber' => '555-555-5555',
      'Yes' => ['Yes'],
      'Company' => 'Tally',
      'JobTitle' => 'Programmer Writer'
    }
    web_form_req_object = DocuSign_WebForms::CreateInstanceRequestBody.new({
      'clientUserId' => args[:client_user_id],
      'formValues' => web_form_values,
      'expirationOffset' => '3600'
    })
    webforms_api.create_instance(args[:account_id], form_id, web_form_req_object)
  end

  private

  def make_web_forms_template
    template_name = args[:template_name]
    doc_file = 'World_Wide_Corp_Web_Form.pdf'
    base64_file_content = Base64.encode64(File.binread(File.join('data', doc_file)))

    # Create the document model
    document = DocuSign_eSign::Document.new({
      # Create the DocuSign document object
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
      'anchorString' => '/SignHere/', 'anchorUnits' => 'pixel',
      'anchorXOffset' => '20', 'anchorYOffset' => '10'
    )
    check = DocuSign_eSign::Checkbox.new(
      'documentId' => '1', 'tabLabel' => 'Yes',
      'anchorString' => '/SMS/', 'anchorUnits' => 'pixel',
      'anchorXOffset' => '20', 'anchorYOffset' => '10'
    )
    text1 = DocuSign_eSign::Text.new(
      'documentId' => '1', 'tabLabel' => 'FullName',
      'anchorString' => '/FullName/', 'anchorUnits' => 'pixel',
      'anchorXOffset' => '20', 'anchorYOffset' => '10'
    )
    text2 = DocuSign_eSign::Text.new(
      'documentId' => '1', 'tabLabel' => 'PhoneNumber',
      'anchorString' => '/PhoneNumber/', 'anchorUnits' => 'pixel',
      'anchorXOffset' => '20', 'anchorYOffset' => '10'
    )
    text3 = DocuSign_eSign::Text.new(
      'documentId' => '1', 'tabLabel' => 'Company',
      'anchorString' => '/Company/', 'anchorUnits' => 'pixel',
      'anchorXOffset' => '20', 'anchorYOffset' => '10'
    )
    text4 = DocuSign_eSign::Text.new(
      'documentId' => '1', 'tabLabel' => 'JobTitle',
      'anchorString' => '/JobTitle/', 'anchorUnits' => 'pixel',
      'anchorXOffset' => '20', 'anchorYOffset' => '10'
    )
    date_signed = DocuSign_eSign::DateSigned.new(
      'documentId' => '1', 'tabLabel' => 'DateSigned',
      'anchorString' => '/Date/', 'anchorUnits' => 'pixel',
      'anchorXOffset' => '20', 'anchorYOffset' => '10'
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
      'description' => 'Example template created via the API',
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
