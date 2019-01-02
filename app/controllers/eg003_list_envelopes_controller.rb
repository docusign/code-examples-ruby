class Eg003ListEnvelopesController < EgController
  skip_before_action :verify_authenticity_token
  def eg_name
    'eg003'
  end
  def get_file_name
    File.basename __FILE__
  end

  def create
    minimum_buffer_min = 3
    token_ok = check_token(minimum_buffer_min)
    if token_ok
      # Call the worker method
      access_token = session['ds_access_token']
      base_url = session['ds_base_path']
      account_id = session['ds_account_id']

      results = worker access_token, base_url, account_id
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
  def worker (access_token, base_url, account_id)
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = base_url
    api_client = DocuSign_eSign::ApiClient.new configuration
    api_client.default_headers['Authorization'] = 'Bearer ' + access_token
    envelope_api = DocuSign_eSign::EnvelopesApi.new api_client

    # Step 1. List the envelopes
    # The Envelopes::listStatusChanges method has many options
    # See https://developers.docusign.com/esign-rest-api/reference/Envelopes/Envelopes/listStatusChange#
    # The list status changes call requires at least a from_date OR
    # a set of envelopeIds. Here we filter using a from_date.
    # Here we set the from_date to filter envelopes for the last month
    # # Use ISO 8601 date format
    options =  DocuSign_eSign::ListStatusChangesOptions.new
    options.from_date = (Date.today - 30).strftime('%Y/%m/%d')
    # Exceptions will be caught by the calling function
    results = envelope_api.list_status_changes account_id, options
  end
  # ***DS.snippet.0.end
end
