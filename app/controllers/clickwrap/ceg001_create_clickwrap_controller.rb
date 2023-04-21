class Clickwrap::Ceg001CreateClickwrapController < EgController
  before_action -> { check_auth('Click') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 1, 'Click') }

  def create
    args = {
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token],
      doc_pdf: File.join('data', Rails.configuration.doc_terms_pdf),
      clickwrap_name: request[:clickwrapName]
    }

    results = Clickwrap::Eg001CreateClickwrapService.new(args).worker

    session[:clickwrap_id] = results.clickwrap_id
    session[:clickwrap_name] = results.clickwrap_name

    @title = @example['ExampleName']
    @message = format_string(@example['ResultsPageText'], results.clickwrap_name)
    @json = results.to_json.to_json
    render 'ds_common/example_done'
  end
end
