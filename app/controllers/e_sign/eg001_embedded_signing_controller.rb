# frozen_string_literal: true

class ESign::Eg001EmbeddedSigningController < EgController
  def create
    minimum_buffer_min = 10
    token_ok = check_token(minimum_buffer_min)
    unless token_ok
      flash[:messages] = 'Sorry, you need to re-authenticate.'
      # We could store the parameters of the requested operation
      # so it could be restarted automatically.
      # But since it should be rare to have a token issue here,
      # we'll make the user re-enter the form data after
      # authentication.
      redirect_to '/ds/mustAuthenticate'
    end
    redirect_url = ESign::Eg001EmbeddedSigningService.new(session, request).call
    redirect_to redirect_url
  end

  def get
    session[:been_here] = true
    super
  end
end
