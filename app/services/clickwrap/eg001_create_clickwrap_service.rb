# frozen_string_literal: true

class Clickwrap::Eg001CreateClickwrapService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    # Step 2. Construct your API headers
    configuration = DocuSign_Click::Configuration.new
    configuration.host = args[:base_path]

    api_client = DocuSign_Click::ApiClient.new configuration
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")

    # Step 3. Construct the request body
    # Create the display settings
    display_settings = DocuSign_Click::DisplaySettings.new(
      consentButtonText: 'I Agree',
      displayName: 'Terms of Service',
      downloadable: true,
      format: 'modal',
      hasAccept: true,
      mustRead: true,
      mustView: true,
      requireAccept: true,
      size: 'medium',
      documentDisplay: 'document'
    )

    # Read file from a local directory
    # The reads could raise an exception if the file is not available!
    doc_pdf = Rails.configuration.doc_terms_pdf
    doc_b64 = Base64.encode64(File.binread(File.join('data', doc_pdf)))

    # Create the document model.
    documents = [
      DocuSign_Click::Document.new(
        documentBase64: doc_b64,
        documentName: 'Terms of Service',
        fileExtension: 'pdf',
        order: 0
      )
    ]

    # Create a clickwrap request model
    clickwrap_request = DocuSign_Click::ClickwrapRequest.new(
      displaySettings: display_settings,
      documents: documents,
      name: args[:clickwrap_name],
      requireReacceptance: true
    )

    # Step 4. Call the Click API
    account_api = DocuSign_Click::AccountsApi.new(api_client)
    account_api.create_clickwrap(args[:account_id], clickwrap_request)
  end
end
