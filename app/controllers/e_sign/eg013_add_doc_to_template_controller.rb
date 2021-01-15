# frozen_string_literal: true

class ESign::Eg013AddDocToTemplateController < EgController
  def create
    minimum_buffer_min = 3
    template_id = session[:template_id]
    token_ok = check_token(minimum_buffer_min)

    if token_ok && template_id
      # 2. Call the worker method
      # More data validation would be a good idea here
      # Strip anything other than characters listed
      begin
        results = ESign::Eg013AddDocToTemplateService.new(request, session, template_id).call
        # which need an envelopeId
        # Redirect the user to the embedded signing
        # Don't use an iFrame!
        # State can be stored/recovered using the framework's session or a
        # query parameter on the returnUrl
        redirect_to results[:redirect_url]
      rescue DocuSign_eSign::ApiError => e
        error = JSON.parse e.response_body
        @error_code = error['errorCode']
        @error_message = error['message']
        render 'ds_common/error'
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
      @title = 'Use embedded signing from template and extra doc',
               @template_ok = false
    end
  end
end
