class ESign::Eg010SendBinaryDocsController < EgController
  def create
    minimum_buffer_min = 3
    if check_token minimum_buffer_min
      begin
        results = ESign::Eg010SendBinaryDocsService.new(request, session).call
        @title = 'Envelope sent'
        @h1 = 'Envelope sent'
        @message = "The envelope has been created and sent!<br/>Envelope ID #{results['envelope_id']}."
        render 'ds_common/example_done'
      rescue Net::HTTPError => e
        if !e.response.nil?
          json_response = JSON.parse e.response
          @error_code = json_response['errorCode']
          @error_message = json_response['message']
        else
          @error_code = 'API request problem'
          @error_message = e.to_s
        end
      end
    else
      flash[:message] = 'Sorry, you need to re-authenticate.'
      # We could store the parameters of the requested operation
      # so it could be restarted automatically.
      # But since it should be rare to have a token issue here,
      # we'll make the user re-enter the form data after
      # authentication.
      session['eg'] = eg_name
      redirect_to '/ds/mustAuthenticate'
    end
  end
end
