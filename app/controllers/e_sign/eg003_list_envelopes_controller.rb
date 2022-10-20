# frozen_string_literal: true

class ESign::Eg003ListEnvelopesController < EgController
  before_action :check_auth
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 3) }

  def create
    args = {
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token]
    }
    results = ESign::Eg003ListEnvelopesService.new(args).worker
    @title = @example['ExampleName']
    @message = @example['ResultsPageText']
    @json =  results.to_json.to_json
    render 'ds_common/example_done'
  end
end
