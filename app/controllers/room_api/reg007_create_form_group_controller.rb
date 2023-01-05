class RoomApi::Reg007CreateFormGroupController < EgController
  before_action -> { check_auth('Rooms') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 7, 'Rooms') }

  def create
    args = {
      group_name: params[:group_name],
      account_id: session[:ds_account_id],
      access_token: session[:ds_access_token]
    }

    results = RoomApi::Eg007CreateFormGroupService.new(args).worker

    @title = @example['ExampleName']
    @message = format_string(@example['ResultsPageText'], results.name)
    @json = results.to_json.to_json

    render 'ds_common/example_done'
  end
end
