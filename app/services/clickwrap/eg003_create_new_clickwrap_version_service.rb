# frozen_string_literal: true

class Clickwrap::Eg003CreateNewClickwrapVersionService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    # Step 2. Construct your API headers
    #ds-snippet-start:Click3Step2
    configuration = DocuSign_Click::Configuration.new
    configuration.host = args[:base_path]

    api_client = DocuSign_Click::ApiClient.new configuration
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    #ds-snippet-end:Click3Step2

    # Step 3. Construct the request body
    # Create a display settings model
    #ds-snippet-start:Click3Step3
    display_settings = DocuSign_Click::DisplaySettings.new(
      consentButtonText: 'I Agree',
      displayName: "#{args[:clickwrap_name]} v2",
      downloadable: false,
      format: 'modal',
      mustRead: true,
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
    #ds-snippet-end:Click3Step3

    # Step 4. Call the Click API
    #ds-snippet-start:Click3Step4
    accounts_api = DocuSign_Click::AccountsApi.new(api_client)
    results, _status, headers = accounts_api.create_clickwrap_version_with_http_info(
      args[:account_id],
      args[:clickwrap_id],
      clickwrap_request
    )

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:Click4Step4

    results
  end
end
