class RoomApi::Eg009AssignFormToFormGroupController < EgController
  before_action :check_auth

  def create
    results = RoomApi::Eg009AssignFormToFormGroupService.new(session, request).call
    result = results.to_json.to_json
    if result['exception']
      @error_code = results[:exception]
      @error_message = "Form may already be assigned to form group."
      render 'ds_common/error'
    else
      @title = "Assigned form to form group"
      @h1 = "Assigned form to form group"
      @message = "Form has been assigned to the selected form group."

      render 'ds_common/example_done'
    end
  end

  def get
    super
    # Step 3 start
    @forms = RoomApi::GetDataService.new(session).get_form_libraries
    # Step 3 end

    # Step 4 start
    @form_groups = RoomApi::GetDataService.new(session).get_form_groups
    # Step 4 end
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
