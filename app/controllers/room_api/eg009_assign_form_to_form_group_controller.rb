class RoomApi::Eg009AssignFormToFormGroupController < EgController
  before_action :check_auth
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 9) }

  def create
    args = {
      form_id: params[:form_id],
      form_group_id: params[:form_group_id],
      account_id: session[:ds_account_id],
      access_token: session[:ds_access_token]
    }

    results = RoomApi::Eg009AssignFormToFormGroupService.new(args).worker
    result = results.to_json.to_json
    if result['exception']
      @error_code = results[:exception]
      @error_message = 'Form may already be assigned to form group.'
      render 'ds_common/error'
    else
      @title = @example['ExampleName']
      @message = 'Form has been assigned to the selected form group.'

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
end
