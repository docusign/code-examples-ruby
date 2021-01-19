class RoomApi::Eg008GrantOfficeAccessToFormGroupController < EgController
  before_action :check_auth

  def create
    results = RoomApi::Eg008GrantOfficeAccessToFormGroupService.new(session, request).call
    result = results.to_json.to_json
    if result['exception']
      @error_code = results[:exception]
      @error_message = "Office may already have access to form group."
      render 'ds_common/error'
    else
      @title = "Granted office access to form group"
      @h1 = "Granted office access to form group"
      @message = "office access has been granted for the form group."
      render 'ds_common/example_done'
    end
      
  end

  def get
    super
    # Step 3. Get an office ID
    @offices = RoomApi::GetDataService.new(session).get_offices
    @form_groups = RoomApi::GetDataService.new(session).get_form_groups
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
