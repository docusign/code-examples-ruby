# frozen_string_literal: true

class ESign::Eg042DocumentGenerationService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    envelope_api = create_envelope_api(args)
    template_api = create_template_api(args)

    account_id = args[:account_id]
    envelope_args = args[:envelope_args]

    #ds-snippet-start:eSign42Step2
    template, _status, headers = template_api.create_template_with_http_info(account_id, template_data)

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end

    template_id = template.template_id
    #ds-snippet-end:eSign42Step2

    #ds-snippet-start:eSign42Step3
    document_id = '1'
    _results, _status, headers = template_api.update_document_with_http_info(account_id, document_id, template_id, template_document(envelope_args))

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:eSign42Step3

    #ds-snippet-start:eSign42Step4
    recipient_id = '1'
    _results, _status, headers = template_api.create_tabs_with_http_info(account_id, recipient_id, template_id, recipient_tabs)

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:eSign42Step4

    #ds-snippet-start:eSign42Step5
    envelope_definition = make_envelope(template_id, envelope_args)
    envelope, _status, headers = envelope_api.create_envelope_with_http_info(account_id, envelope_definition)

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end

    envelope_id = envelope.envelope_id
    #ds-snippet-end:eSign42Step5

    #ds-snippet-start:eSign42Step6
    doc_gen_form_fields_response, _status, headers = envelope_api.get_envelope_doc_gen_form_fields_with_http_info(account_id, envelope_id)

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end

    document_id_guid = doc_gen_form_fields_response.doc_gen_form_fields[0].document_id
    #ds-snippet-end:eSign42Step6

    #ds-snippet-start:eSign42Step7
    form_fields_request = form_fields(envelope_args, document_id_guid)
    _results, _status, headers = envelope_api.update_envelope_doc_gen_form_fields_with_http_info(
      account_id,
      envelope_id,
      form_fields_request
    )

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:eSign42Step7

    #ds-snippet-start:eSign42Step8
    send_envelope_req = DocuSign_eSign::Envelope.new(status: 'sent')
    envelope, _status, headers = envelope_api.update_with_http_info(account_id, envelope_id, send_envelope_req)

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:eSign42Step8

    { 'envelope_id' => envelope.envelope_id }
  end

  private

  #ds-snippet-start:eSign42Step2
  def template_data
    # Create recipients
    signer = DocuSign_eSign::Signer.new(
      roleName: 'signer',
      recipientId: '1',
      routingOrder: '1'
    )
    recipients = DocuSign_eSign::Recipients.new(
      signers: [signer]
    )

    # Create the envelope template model
    DocuSign_eSign::EnvelopeTemplate.new(
      name: 'Example document generation template',
      description: 'Example template created via the API',
      emailSubject: 'Please sign this document',
      shared: 'false',
      recipients: recipients,
      status: 'created'
    )
  end
  #ds-snippet-end:eSign42Step2

  #ds-snippet-start:eSign42Step3
  def template_document(args)
    # Create the document model
    document = DocuSign_eSign::Document.new(
      documentBase64: Base64.encode64(File.binread(args[:doc_file])),
      name: 'OfferLetterDemo.docx',
      fileExtension: 'docx',
      documentId: 1,
      order: 1,
      pages: 1
    )

    DocuSign_eSign::EnvelopeDefinition.new(
      documents: [document]
    )
  end
  #ds-snippet-end:eSign42Step3

  #ds-snippet-start:eSign42Step4
  def recipient_tabs
    # Create tabs
    sign_here = DocuSign_eSign::SignHere.new(
      anchorString: 'Employee Signature',
      anchorUnits: 'pixels',
      anchorXOffset: '5',
      anchorYOffset: '-22'
    )
    date_signed = DocuSign_eSign::DateSigned.new(
      anchorString: 'Date Signed',
      anchorUnits: 'pixels',
      anchorYOffset: '-22'
    )
    DocuSign_eSign::Tabs.new(
      signHereTabs: [sign_here],
      dateSignedTabs: [date_signed]
    )
  end
  #ds-snippet-end:eSign42Step4

  #ds-snippet-start:eSign42Step5
  def make_envelope(template_id, args)
    # Create the signer model
    signer = DocuSign_eSign::TemplateRole.new(
      email: args[:candidate_email],
      name: args[:candidate_name],
      roleName: 'signer'
    )

    # Create the envelope model
    DocuSign_eSign::EnvelopeDefinition.new(
      templateRoles: [signer],
      status: 'created',
      templateId: template_id
    )
  end
  #ds-snippet-end:eSign42Step5

  #ds-snippet-start:eSign42Step7
  def form_fields(args, document_id_guid)
    bonus_value = '20%'

    candidate_name_field = DocuSign_eSign::DocGenFormField.new(
      name: 'Candidate_Name',
      value: args[:candidate_name]
    )
    manager_name_field = DocuSign_eSign::DocGenFormField.new(
      name: 'Manager_Name',
      value: args[:manager_name]
    )
    job_title_field = DocuSign_eSign::DocGenFormField.new(
      name: 'Job_Title',
      value: args[:job_title]
    )
    start_date_field = DocuSign_eSign::DocGenFormField.new(
      name: 'Start_Date',
      value: args[:start_date]
    )

    salary_row = DocuSign_eSign::DocGenFormFieldRowValue.new(
      docGenFormFieldList: [
        DocuSign_eSign::DocGenFormField.new(
          name: 'Compensation_Component',
          value: 'Salary'
        ),
        DocuSign_eSign::DocGenFormField.new(
          name: 'Details',
          value: "$#{args[:salary]}"
        )
      ]
    )
    bonus_row = DocuSign_eSign::DocGenFormFieldRowValue.new(
      docGenFormFieldList: [
        DocuSign_eSign::DocGenFormField.new(
          name: 'Compensation_Component',
          value: 'Bonus'
        ),
        DocuSign_eSign::DocGenFormField.new(
          name: 'Details',
          value: bonus_value
        )
      ]
    )
    rsus_row = DocuSign_eSign::DocGenFormFieldRowValue.new(
      docGenFormFieldList: [
        DocuSign_eSign::DocGenFormField.new(
          name: 'Compensation_Component',
          value: 'RSUs'
        ),
        DocuSign_eSign::DocGenFormField.new(
          name: 'Details',
          value: args[:rsus]
        )
      ]
    )
    compensation_package = DocuSign_eSign::DocGenFormField.new(
      name: 'Compensation_Package',
      type: 'TableRow',
      rowValues: [salary_row, bonus_row, rsus_row]
    )
    doc_gen_form_fields_list = [
      candidate_name_field, manager_name_field, job_title_field, start_date_field, compensation_package
    ]

    doc_gen_form_fields = DocuSign_eSign::DocGenFormFields.new(
      documentId: document_id_guid,
      docGenFormFieldList: doc_gen_form_fields_list
    )

    DocuSign_eSign::DocGenFormFieldRequest.new(
      docGenFormFields: [doc_gen_form_fields]
    )
  end
  #ds-snippet-end:eSign42Step7
end
