class RoomApi::Reg008GrantOfficeAccessToFormGroupController < EgController
  before_action -> { check_auth('Rooms') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 8, 'Rooms') }

  def create
    args = {
      office_id: params[:office_id],
      form_group_id: params[:form_group_id],
      account_id: session[:ds_account_id],
      access_token: session[:ds_access_token]
    }

    results = RoomApi::Eg008GrantOfficeAccessToFormGroupService.new(args).worker
    result = results.to_json.to_json
    if result['exception']
      @error_code = results[:exception]
      @error_message = 'Office may already have access to form group.'
      render 'ds_common/error'
    else
      @title = @example['ExampleName']
      @message = 'office access has been granted for the form group.'
      render 'ds_common/example_done'
    end
  end

  def get
    super
    # Step 3 start
    @offices = RoomApi::GetDataService.new(session).get_offices
    # Step 3 end

    # Step 4 start
    @form_groups = RoomApi::GetDataService.new(session).get_form_groups
    # Step 4 end
  end
end
