# frozen_string_literal: true

class ESign::Eg017SetTemplateTabValuesController < EgController
  def create
    minimum_buffer_min = 3
    template_id = session[:template_id]
    token_ok = check_token(minimum_buffer_min)
    if token_ok && template_id
        redirect_url = ESign::Eg017Service.new(request, session, template_id).call
        redirect_to redirect_url
    elsif !token_ok
      flash[:messages] = 'Sorry, you need to re-authenticate.'
      # We could store the parameters of the requested operation so it could be restarted
      # automatically. But since it should be rare to have a token issue here,
      # we'll make the user re-enter the form data after authentication
      redirect_to '/ds/mustAuthenticate'
    elsif !template_id
      @title = 'Use a template to send an envelope'
      @template_ok = false
    end
  end
end
