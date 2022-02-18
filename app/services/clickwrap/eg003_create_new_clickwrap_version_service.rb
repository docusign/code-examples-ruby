# frozen_string_literal: true

class Clickwrap::Eg003CreateNewClickwrapVersionService
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
    # Create a display settings model
    display_settings = DocuSign_Click::DisplaySettings.new(
      consentButtonText: 'I Agree',
      displayName: "#{args[:clickwrap_name]} v2",
      downloadable: false,
      format: 'modal',
      mustRead: true,
      mustView: false,
      requireAccept: false,
      documentDisplay: 'document',
      sendToEmail: false
    )

    # Read file from a local directory
    # The reads could raise an exception if the file is not available!
    doc_pdf = Rails.configuration.doc_terms_pdf
    doc_b64 = Base64.encode64(File.binread(File.join('data', doc_pdf)))

    # Create a document model.
    document = DocuSign_Click::Document.new(
      documentBase64: doc_b64,
      documentName: 'Terms of Service', # Can be different from actual file name
      fileExtension: 'pdf', # pdf, doc, html document types are accepted
      order: 0
    )

    # Create a clickwrap request model
    clickwrap_request = DocuSign_Click::ClickwrapRequest.new(
      displaySettings: display_settings,
      documents: [document],
      name: args[:clickwrap_name],
      requireReacceptance: true,
      status: 'active'
    )

    # Step 4. Call the Click API
    accounts_api = DocuSign_Click::AccountsApi.new(api_client)
    accounts_api.create_clickwrap_version(
      args[:account_id],
      args[:clickwrap_id],
      clickwrap_request
    )
  end
end
