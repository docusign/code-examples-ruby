class RoomApi::Eg007CreateFormGroupController < EgController
  before_action :check_auth

  def create
    args = {
      group_name: params[:group_name],
      account_id: session[:ds_account_id],
      access_token: session[:ds_access_token]
    }

    results = RoomApi::Eg007CreateFormGroupService.new(args).worker

    @title = "The form group was successfully created"
    @h1 = "The form group was successfully created"
    @message = "The form group was created! form group ID: #{results.form_group_id}, Name: #{results.name}"
    @json = results.to_json.to_json

    render 'ds_common/example_done'
  end
end
