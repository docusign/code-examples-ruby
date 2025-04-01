# frozen_string_literal: true

class ConnectedFields::Eg001SetConnectedFieldsService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def get_tab_groups
    #ds-snippet-start:ConnectedFields1Step2
    headers = {
      'Authorization' => "Bearer #{args[:access_token]}",
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }
    #ds-snippet-end:ConnectedFields1Step2

    #ds-snippet-start:ConnectedFields1Step3
    url = URI("#{args[:extensions_base_path]}/v1/accounts/#{args[:account_id]}/connected-fields/tab-groups")
    response = Net::HTTP.get_response(url, headers)
    response_data = JSON.parse(response.body)

    filtered_apps = response_data.select do |app|
      app['tabs']&.any? do |tab|
        (tab['extensionData']&.dig('actionContract')&.include? 'Verify') ||
          (tab['tabLabel']&.include? 'connecteddata')
      end
    end

    # return unique apps
    filtered_apps.uniq { |app| app['appId'] }
    #ds-snippet-end:ConnectedFields1Step3
  end

  #ds-snippet-start:ConnectedFields1Step4
  def extract_verification_data(selected_app_id, tab)
    extension_data = tab['extensionData']

    {
      app_id: selected_app_id,
      extension_group_id: extension_data['extensionGroupId'],
      publisher_name: extension_data['publisherName'],
      application_name: extension_data['applicationName'],
      action_name: extension_data['actionName'],
      action_input_key: extension_data['actionInputKey'],
      action_contract: extension_data['actionContract'],
      extension_name: extension_data['extensionName'],
      extension_contract: extension_data['extensionContract'],
      required_for_extension: extension_data['requiredForExtension'],
      tab_label: tab['tabLabel'],
      connection_key: extension_data['connectionInstances']&.dig(0, 'connectionKey') || '',
      connection_value: extension_data['connectionInstances']&.dig(0, 'connectionValue') || ''
    }
  end
  #ds-snippet-end:ConnectedFields1Step4

  def send_envelope(app)
    # Create the envelope definition
    #ds-snippet-start:ConnectedFields1Step6
    envelope = make_envelope args[:envelope_args], app

    # Call Docusign to create the envelope
    envelope_api = create_envelope_api(args)

    results = envelope_api.create_envelope args[:account_id], envelope

    { 'envelope_id' => results.envelope_id }
    #ds-snippet-end:ConnectedFields1Step6
  end

  private

  #ds-snippet-start:ConnectedFields1Step5
  def make_envelope(envelope_args, app)
    doc = DocuSign_eSign::Document.new
    doc.document_base64 = Base64.encode64(File.binread(envelope_args[:doc_pdf]))
    doc.name = 'Lorem Ipsum'
    doc.file_extension = 'pdf'
    doc.document_id = '1'

    # The order in the docs array determines the order in the envelope
    # Create a signer recipient to sign the document, identified by name and email
    # We're setting the parameters via the object creation
    signer = DocuSign_eSign::Signer.new
    signer.email = envelope_args[:signer_email]
    signer.name = envelope_args[:signer_name]
    signer.recipient_id = 1

    # The Docusign platform searches throughout your envelope's documents for matching
    # anchor strings. So the sign_here_2 tab will be used in both document 2 and 3
    # since they use the same anchor string for their "signer 1" tabs.
    sign_here = DocuSign_eSign::SignHere.new
    sign_here.anchor_string = '/sn1/'
    sign_here.anchor_units = 'pixels'
    sign_here.anchor_x_offset = '20'
    sign_here.anchor_y_offset = '10'

    text_tabs = []
    app['tabs'].each do |tab|
      next if tab['tabLabel'].include?('SuggestionInput')

      verification_data = extract_verification_data(app['appId'], tab)
      text_tabs.push(text_tab(verification_data, text_tabs.length))
    end

    tabs = DocuSign_eSign::Tabs.new
    tabs.sign_here_tabs = [sign_here]
    tabs.text_tabs = text_tabs
    signer.tabs = tabs

    recipients = DocuSign_eSign::Recipients.new
    recipients.signers = [signer]

    envelope_definition = DocuSign_eSign::EnvelopeDefinition.new
    envelope_definition.email_subject = 'Please sign this document'
    envelope_definition.documents = [doc]
    envelope_definition.recipients = recipients
    envelope_definition.status = 'sent'
    envelope_definition
  end

  def extension_data(verification_data)
    {
      extensionGroupId: verification_data[:extension_group_id],
      publisherName: verification_data[:publisher_name],
      applicationId: verification_data[:app_id],
      applicationName: verification_data[:application_name],
      actionName: verification_data[:action_name],
      actionContract: verification_data[:action_contract],
      extensionName: verification_data[:extension_name],
      extensionContract: verification_data[:extension_contract],
      requiredForExtension: verification_data[:required_for_extension],
      actionInputKey: verification_data[:action_input_key],
      extensionPolicy: 'MustVerifyToSign',
      connectionInstances: [
        {
          connectionKey: verification_data[:connection_key],
          connectionValue: verification_data[:connection_value]
        }
      ]
    }
  end

  def text_tab(verification_data, text_tabs_count)
    {
      requireInitialOnSharedChange: false,
      requireAll: false,
      name: verification_data[:application_name],
      required: true,
      locked: false,
      disableAutoSize: false,
      maxLength: 4000,
      tabLabel: verification_data[:tab_label],
      font: 'lucidaconsole',
      fontColor: 'black',
      fontSize: 'size9',
      documentId: '1',
      recipientId: '1',
      pageNumber: '1',
      xPosition: (70 + 100 * (text_tabs_count / 10)).to_s,
      yPosition: (560 + 20 * (text_tabs_count % 10)).to_s,
      width: '84',
      height: '22',
      templateRequired: false,
      tabType: 'text',
      tooltip: verification_data[:action_input_key],
      extensionData: extension_data(verification_data)
    }
  end
  #ds-snippet-end:ConnectedFields1Step5
end
