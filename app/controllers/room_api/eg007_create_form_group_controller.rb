class RoomApi::Eg007CreateFormGroupController < EgController
  before_action :check_auth

  def create
    results = RoomApi::Eg007CreateFormGroupService.new(session, request).call

    @title = "The form group was successfully created"
    @h1 = "The form group was successfully created"
    @message = "The form group was created! form group ID: #{results.form_group_id}, Name: #{results.name}"
    @json = results.to_json.to_json

    render 'ds_common/example_done'
  end

  private

  def check_auth
    minimum_buffer_min = 10
    token_ok = check_token(minimum_buffer_min)
    unless token_ok
      flash[:messages] = 'Sorry, you need to re-authenticate.'
      # We could store the parameters of the requested operation so it could be restarted automatically
      # But since it should be rare to have a token issue here, we'll make the user re-enter the form data after authentication
      redirect_to '/ds/mustAuthenticate'
    end
  end
end
