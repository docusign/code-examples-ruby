class RoomApi::Reg009AssignFormToFormGroupController < EgController
  before_action -> { check_auth('Rooms') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 9, 'Rooms') }

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
    #ds-snippet-start:Rooms9Step3
    @forms = RoomApi::GetDataService.new(session).get_form_libraries
    #ds-snippet-end:Rooms9Step3

    #ds-snippet-start:Rooms9Step4
    @form_groups = RoomApi::GetDataService.new(session).get_form_groups
    #ds-snippet-end:Rooms9Step4
  end
end
