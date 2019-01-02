class Eg011EmbeddedSendingController < EgController
  skip_before_action :verify_authenticity_token
  def eg_name
    "eg011"
  end
  def get_file_name
    File.basename __FILE__
  end

  def create
    minimum_buffer_min = 10
    token_ok = check_token(minimum_buffer_min)

    if token_ok
      # Call the worker method
      # More data validation would be a good idea here
      envelope_args = {
          :signer_email => request.params['signerEmail'].gsub(/([^\w \-\@\.\,])+/, ''),
          :signer_name => request.params['signerName'].gsub(/([^\w \-\@\.\,])+/, ''),
          :cc_email => request.params['ccEmail'].gsub(/([^\w \-\@\.\,])+/, ''),
          :cc_name => request.params['ccName'].gsub(/([^\w \-\@\.\,])+/, ''),
      }

      args = {
          :account_id => session['ds_account_id'],
          :base_path => session['ds_base_path'],
          :access_token => session['ds_access_token'],
          :starting_view => request.params['starting_view'].gsub(/([^\w \-\@\.\,])+/, ''),
          :envelope_args => envelope_args,
          :ds_return_url => "#{Rails.application.config.app_url}/ds_common-return"
      }

      begin
        results = worker args
        redirect_to results['redirect_url']
      rescue  DocuSign_eSign::ApiError => e
        error = JSON.parse e.response_body
        @error_code = error['errorCode']
        @error_message = error['message']
        render "ds_common/error"
      end
    elsif !token_ok
      flash[:messages] = 'Sorry, you need to re-authenticate.'
      # We could store the parameters of the requested operation
      # so it could be restarted automatically.
      # But since it should be rare to have a token issue here,
      # we'll make the user re-enter the form data after
      # authentication.
      redirect_to '/ds/mustAuthenticate'
    elsif !template_id
      @title = 'Use a template to send an envelope'
      @template_ok = false
    end
  end

  # ***DS.snippet.0.start
  def worker(args)
    # 1. Create the envelope as a draft using eg002's worker
    # Exceptions will be caught by the calling function
    args[:envelope_args][:status] = 'created'
    eg = Eg002SigningViaEmailController.new
    results = eg.worker args
    envelope_id = results['envelope_id']
    # 2. Create sender view
    view_request = DocuSign_eSign::ReturnUrlRequest.new({returnUrl: args[:ds_return_url]})
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:base_path]
    api_client = DocuSign_eSign::ApiClient.new configuration
    api_client.default_headers["Authorization"] = "Bearer #{args[:access_token]}"
    envelope_api =  DocuSign_eSign::EnvelopesApi.new api_client
    results = envelope_api.create_sender_view args[:account_id], envelope_id, view_request
    # Switch to the Recipients / Documents view if requested by the user in the form
    url = results.url
    if args[:starting_view] == "recipient"
      url = url.sub! 'send=1', 'send=0'
    end

    return {'envelope_id' => envelope_id, 'redirect_url' =>  url}
  end
  # ***DS.snippet.0.end
end