class Eg018GetEnvelopeCustomFieldDataController < EgController
  skip_before_action :verify_authenticity_token
  def eg_name
    'eg018'
  end
  def get_file_name
    File.basename __FILE__
  end

  def create
    minimum_buffer_min = 3
    envelope_id = session[:envelope_id]? session[:envelope_id] : nil
    token_ok = check_token(minimum_buffer_min)
    if token_ok
      # Call the worker method
      access_token = session['ds_access_token']
      base_url = session['ds_base_path']
      account_id = session['ds_account_id']

      results = worker access_token, base_url, account_id, envelope_id
      @h1 = 'List envelopes results'
      @message = 'Results from the Envelopes::listStatusChanges method:'
      @json =  results.to_json.to_json
      render 'ds_common/example_done'
    else
      flash[:messages] = 'Sorry, you need to re-authenticate.'
      # We could store the parameters of the requested operation
      # so it could be restarted automatically.
      # But since it should be rare to have a token issue here,
      # we'll make the user re-enter the form data after
      # authentication.
      redirect_to '/ds/mustAuthenticate'
    end
  end

  # ***DS.snippet.0.start
  def worker (access_token, base_url, account_id, envelope_id)
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = base_url
    api_client = DocuSign_eSign::ApiClient.new configuration
    api_client.default_headers['Authorization'] = 'Bearer ' + access_token
    envelope_api = DocuSign_eSign::EnvelopesApi.new api_client

    # Step 1. List the envelope custom fields
    # The Envelopes::getEnvelopeFormData method has many options
    # See https://developers.docusign.com/esign-rest-api/reference/Envelopes/EnvelopeFormData/get
    # The get custom fields call requires an account ID and an envelope ID

    # Exceptions will be caught by the calling function
    results = envelope_api.list_custom_fields account_id, envelope_id
  end
  # ***DS.snippet.0.end
end
