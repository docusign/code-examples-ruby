class ESign::Eeg028BrandsCreatingController < EgController
  before_action -> { check_auth('eSignature') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 28, 'eSignature') }

  def create
    args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      brandName: params[:brandName],
      defaultBrandLanguage: params[:defaultBrandLanguage]
    }

    results  = ESign::Eg028BrandsCreatingService.new(args).worker
    # Step 4. a) Call the eSignature API
    #         b) Display the JSON response
    brand_id = results.brands[0].brand_id
    @title = @example['ExampleName']
    @message = format_string(@example['ResultsPageText'], brand_id)
    @json = results.to_json.to_json
    render 'ds_common/example_done'
  rescue DocuSign_eSign::ApiError => e
    handle_error(e)
  end
end
