# frozen_string_literal: true

class ESign::Eg008CreateTemplateService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    templates_api = create_template_api(args)
    # Step 1. Does the template exist? Try to look it up by name
    options = DocuSign_eSign::ListTemplatesOptions.new
    options.search_text = args[:template_name]
    results, _status, headers = templates_api.list_templates_with_http_info(args[:account_id], options)

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end

    created_new_template = false

    if results.result_set_size.to_i.positive?
      template_id = results.envelope_templates[0].template_id
      results_template_name = results.envelope_templates[0].name
    else
      # Template not found -- so create it
      # Step 2 create the template
      #ds-snippet-start:eSign8Step3
      template_req_object = make_template_req
      result, _status, headers = templates_api.create_template_with_http_info(args[:account_id], template_req_object)

      remaining = headers['X-RateLimit-Remaining']
      reset = headers['X-RateLimit-Reset']

      if remaining && reset
        reset_date = Time.at(reset.to_i).utc
        puts "API calls remaining: #{remaining}"
        puts "Next Reset: #{reset_date}"
      end
      #ds-snippet-end:eSign8Step3
      created_new_template = true

      # Retreive the new template ID
      template_id = result.template_id
      results_template_name = result.name
    end
    {
      template_id: template_id,
      template_name: results_template_name,
      created_new_template: created_new_template
    }
  end

  #ds-snippet-start:eSign8Step2
  def make_template_req
    # document 1 is a PDF
    #
    # The template has two recipient roles.
    # recipient 1 - signer
    # recipient 2 - cc
    #
    # Read the PDF from the disk
    # Read files 2 and 3 from a local directory
    # The reads could raise an exception if the file is not available!
    template_name = args[:template_name]
    doc_file = 'World_Wide_Corp_fields.pdf'
    base64_file_content = Base64.encode64(File.binread(File.join('data', doc_file)))

    # Create the document model
    document = DocuSign_eSign::Document.new({
                                              # Create the Docusign document object
                                              'documentBase64' => base64_file_content,
                                              'name' => 'Lorem Ipsum', # Can be different from actual file name
                                              'fileExtension' => 'pdf', # Many different document types are accepted
                                              'documentId' => '1' # A label used to reference the doc
                                            })

    # Create the signer recipient model
    # Since these are role definitions, no name/email:
    signer = DocuSign_eSign::Signer.new({
                                          'roleName' => 'signer', 'recipientId' => '1', 'routingOrder' => '1'
                                        })
    # Create a cc recipient to receive a copy of the documents
    cc = DocuSign_eSign::CarbonCopy.new({
                                          'roleName' => 'cc', 'recipientId' => '2', 'routingOrder' => '2'
                                        })
    # Create fields using absolute positioning
    # Create a sign_here tab (field on the document)
    sign_here = DocuSign_eSign::SignHere.new(
      'documentId' => '1', 'pageNumber' => '1',
      'xPosition' => '191', 'yPosition' => '148'
    )
    check1 = DocuSign_eSign::Checkbox.new(
      'documentId' => '1', 'pageNumber' => '1',
      'xPosition' => '75', 'yPosition' => '417', 'tabLabel' => 'ckAuthorization'
    )
    check2 = DocuSign_eSign::Checkbox.new(
      'documentId' => '1', 'pageNumber' => '1',
      'xPosition' => '75', 'yPosition' => '447', 'tabLabel' => 'ckAuthentication'
    )
    check3 = DocuSign_eSign::Checkbox.new(
      'documentId' => '1', 'pageNumber' => '1',
      'xPosition' => '75', 'yPosition' => '478', 'tabLabel' => 'ckAgreement'
    )
    check4 = DocuSign_eSign::Checkbox.new(
      'documentId' => '1', 'pageNumber' => '1',
      'xPosition' => '75', 'yPosition' => '508', 'tabLabel' => 'ckAcknowledgement'
    )

    list1 = DocuSign_eSign::List.new(
      'documentId' => '1',
      'pageNumber' => '1',
      'xPosition' => '142',
      'yPosition' => '291',
      'font' => 'helvetica',
      'fontSize' => 'size14',
      'tabLabel' => 'list',
      'required' => 'false',
      'listItems' => [
        DocuSign_eSign::ListItem.new('text' => 'Red', 'value' => 'red'),
        DocuSign_eSign::ListItem.new('text' => 'Orange', 'value' => 'orange'),
        DocuSign_eSign::ListItem.new('text' => 'Yellow', 'value' => 'yellow'),
        DocuSign_eSign::ListItem.new('text' => 'Green', 'value' => 'green'),
        DocuSign_eSign::ListItem.new('text' => 'Blue', 'value' => 'blue'),
        DocuSign_eSign::ListItem.new('text' => 'Indigo', 'value' => 'indigo'),
        DocuSign_eSign::ListItem.new('text' => 'Violet', 'value' => 'violet')
      ]
    )

    numerical = DocuSign_eSign::Numerical.new(
      'documentId' => '1', 'pageNumber' => '1',
      'xPosition' => '163', 'yPosition' => '260',
      'font' => 'helvetica', 'fontSize' => 'size14', 'validationType' => 'Currency',
      'tabLabel' => 'numericalCurrency', 'width' => '84', 'required' => 'false'
    )
    radio_group =  DocuSign_eSign::RadioGroup.new(
      'documentId' => '1', 'groupName' => 'radio1',
      'radios' => [
        DocuSign_eSign::Radio.new('pageNumber' => '1', 'xPosition' => '142',
                                  'yPosition' => '384', 'value' => 'white',
                                  'required' => 'false'),
        DocuSign_eSign::Radio.new('pageNumber' => '1', 'xPosition' => '74',
                                  'yPosition' => '384', 'value' => 'red',
                                  'required' => 'false'),
        DocuSign_eSign::Radio.new('pageNumber' => '1', 'xPosition' => '220',
                                  'yPosition' => '384', 'value' => 'blue',
                                  'required' => 'false')
      ]
    )

    text = DocuSign_eSign::Text.new(
      'documentId' => '1', 'pageNumber' => '1',
      'xPosition' => '153', 'yPosition' => '230',
      'font' => 'helvetica', 'fontSize' => 'size14',
      'tabLabel' => 'text', 'height' => '23',
      'width' => '84', 'required' => 'false'
    )
    # Add the tabs model to the signer
    # The Tabs object takes arrays of the different field/tab types
    signer.tabs = DocuSign_eSign::Tabs.new(
      'signHereTabs' => [sign_here],
      'checkboxTabs' => [check1, check2, check3, check4],
      'listTabs' => [list1],
      'numericalTabs' => [numerical],
      'radioGroupTabs' => [radio_group],
      'textTabs' => [text]
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
        'signers' => [signer], 'carbonCopies' => [cc]
      ),
      'status' => 'created'
    )
  end
  #ds-snippet-end:eSign8Step2
end
