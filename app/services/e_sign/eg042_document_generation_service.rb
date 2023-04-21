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

    # Step 1. Create the template
    template = template_api.create_template(account_id, template_data)
    template_id = template.template_id

    # Step 2. Update template document
    document_id = '1'
    template_api.update_document(account_id, document_id, template_id, template_document(envelope_args))

    # Step 3. Update recipient tabs
    recipient_id = '1'
    template_api.create_tabs(account_id, recipient_id, template_id, recipient_tabs)

    # Step 4. Create draft envelope
    envelope_definition = make_envelope(template_id, envelope_args)
    envelope = envelope_api.create_envelope(account_id, envelope_definition)
    envelope_id = envelope.envelope_id

    # Step 5: Get the document id
    doc_gen_form_fields_response = envelope_api.get_envelope_doc_gen_form_fields(account_id, envelope_id)
    document_id_guid = doc_gen_form_fields_response.doc_gen_form_fields[0].document_id

    # Step 6: Merge the data fields
    form_fields_request = form_fields(envelope_args, document_id_guid)
    envelope_api.update_envelope_doc_gen_form_fields(
      account_id,
      envelope_id,
      form_fields_request
    )

    # Step 7. Send the envelope
    send_envelope_req = DocuSign_eSign::Envelope.new(status: 'sent')
    envelope = envelope_api.update(account_id, envelope_id, send_envelope_req)
    { 'envelope_id' => envelope.envelope_id }
  end

  private

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

  def recipient_tabs
    # Create tabs
    sign_here = DocuSign_eSign::SignHere.new(
      anchorString: 'Employee Signature',
      anchorUnits: 'pixels',
      anchorXOffset: '5',
      anchorYOffset: '-22'
    )
    date_signed = DocuSign_eSign::DateSigned.new(
      anchorString: 'Date',
      anchorUnits: 'pixels',
      anchorYOffset: '-22'
    )
    DocuSign_eSign::Tabs.new(
      signHereTabs: [sign_here],
      dateSignedTabs: [date_signed]
    )
  end

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

  def form_fields(args, document_id_guid)
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
    salary_field = DocuSign_eSign::DocGenFormField.new(
      name: 'Salary',
      value: args[:salary]
    )
    start_date_field = DocuSign_eSign::DocGenFormField.new(
      name: 'Start_Date',
      value: args[:start_date]
    )
    doc_gen_form_fields_list = [
      candidate_name_field, manager_name_field, salary_field, job_title_field, start_date_field
    ]

    doc_gen_form_fields = DocuSign_eSign::DocGenFormFields.new(
      documentId: document_id_guid,
      docGenFormFieldList: doc_gen_form_fields_list
    )

    DocuSign_eSign::DocGenFormFieldRequest.new(
      docGenFormFields: [doc_gen_form_fields]
    )
  end
end
