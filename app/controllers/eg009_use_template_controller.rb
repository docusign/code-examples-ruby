class Eg009UseTemplateController < EgController
  skip_before_action :verify_authenticity_token
  def eg_name
    "eg009"
  end
  def get_file_name
    File.basename __FILE__
  end

  def create
    minimum_buffer_min = 3
    template_id = session[:template_id]? session[:template_id] : nil
    token_ok = check_token(minimum_buffer_min)

    if token_ok && template_id
      # 2. Call the worker method
      # More data validation would be a good idea here
      # Strip anything other than characters listed
      envelope_args = {
          :signer_email => request.params['signerEmail'],
          :signer_name => request.params['signerName'],
          :cc_email => request.params['ccEmail'],
          :cc_name => request.params['ccName'],
          :template_id => template_id
      }

      args = {
          :account_id => session['ds_account_id'],
          :base_path => session['ds_base_path'],
          :access_token => session['ds_access_token'],
          :envelope_args => envelope_args
      }

      begin
        results = worker args
        # results is an object that implements ArrayAccess. Convert to a regular array:
        @title = 'Envelope sent'
        @h1 = 'Envelope sent'
        @message = "The envelope has been created and sent!<br/>Envelope ID #{results["envelope_id"]}."
        render 'ds_common/example_done'
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
      envelope_args = args[:envelope_args]
      # 1. Create the envelope request object
      envelope_definition = make_envelope(envelope_args)
      # 2. call Envelopes::create API method
      # Exceptions will be caught by the calling function
      configuration = DocuSign_eSign::Configuration.new
      configuration.host = args[:base_path]
      api_client = DocuSign_eSign::ApiClient.new configuration
      api_client.default_headers["Authorization"] = "Bearer #{args[:access_token]}"
      envelope_api = DocuSign_eSign::EnvelopesApi.new(api_client)
      results = envelope_api.create_envelope args[:account_id], envelope_definition
      envelope_id = results.envelope_id
      {'envelope_id' => envelope_id}
  end

  def make_envelope(args)
      # create the envelope definition with the template_id
      envelope_definition = DocuSign_eSign::EnvelopeDefinition.new({
            :status => 'sent',
            :templateId => args[:template_id]
      })
      # Create the template role elements to connect the signer and cc recipients
      # to the template
      signer = DocuSign_eSign::TemplateRole.new({
              :email => args[:signer_email],
              :name => args[:signer_name],
              :roleName => 'signer'
      })
      # Create a cc template role.
      cc = DocuSign_eSign::TemplateRole.new({
              :email => args[:cc_email],
              :name => args[:cc_name],
              :roleName => 'cc'
      })
      # Add the TemplateRole objects to the envelope object
      envelope_definition.template_roles = [signer, cc]
      envelope_definition
  end
  # ***DS.snippet.0.end
end
