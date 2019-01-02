class Eg012EmbeddedConsoleController < EgController
  skip_before_action :verify_authenticity_token
  def eg_name
    "eg012"
  end
  def get_file_name
    File.basename __FILE__
  end

  def create
    minimum_buffer_min = 3
    envelope_id = session[:envelope_id]? session[:envelope_id] : nil
    token_ok = check_token(minimum_buffer_min)

    if token_ok
      # 2. Call the worker method
      # More data validation would be a good idea here
      # Strip anything other than characters listed
      args = {
          :account_id => session['ds_account_id'],
          :base_path => session['ds_base_path'],
          :access_token => session['ds_access_token'],
          :envelope_id => envelope_id,
          :starting_view => request.params['starting_view'],
          :ds_return_url => "#{Rails.application.config.app_url}/ds_common-return"
      }
      begin
        results = worker args
        redirect_to results['redirect_url']
      rescue DocuSign_eSign::ApiError => e
        error = JSON.parse e.response_body
        @error_code = error['errorCode']
        @error_message = error['message']
        render "ds_common/error"
      end
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
  def worker(args)
    # Step 1. Create the NDSE view request object
    # Exceptions will be caught by the calling function
    view_request = DocuSign_eSign::ConsoleViewRequest.new({
        :returnUrl => args[:ds_return_url]})
    if args[:starting_view] == "envelope" && args[:envelope_id]
        view_request.envelope_id = args[:envelope_id]
    end
    # 2. Call the API method
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:base_path]
    api_client = DocuSign_eSign::ApiClient.new configuration
    api_client.default_headers["Authorization"] = "Bearer #{args[:access_token]}"
    envelope_api =  DocuSign_eSign::EnvelopesApi.new api_client
    results = envelope_api.create_console_view args[:account_id], view_request
    {'redirect_url' =>  results.url}
  end
  # ***DS.snippet.0.end
end