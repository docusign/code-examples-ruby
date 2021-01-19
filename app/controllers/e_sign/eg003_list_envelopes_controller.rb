# frozen_string_literal: true

class ESign::Eg003ListEnvelopesController < EgController
  def create
    minimum_buffer_min = 3
    token_ok = check_token(minimum_buffer_min)
    if token_ok
      results = ESign::Eg003ListEnvelopesService.new(session).call
      @h1 = 'List envelopes results'
      @message = 'Results from the Envelopes::listStatusChanges method:'
      @json =  results.to_json.to_json
      render 'ds_common/example_done'
    else
      flash[:messages] = 'Sorry, you need to re-authenticate.'
      # We could store the parameters of the requested operation so it could be restarted automatically.
      # But since it should be rare to have a token issue here, we'll make the user re-enter the form data after authentication.
      redirect_to '/ds/mustAuthenticate'
    end
  end
end
