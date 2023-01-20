class Clickwrap::Ceg006EmbedClickwrapController < EgController
  before_action -> { check_auth('Click') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 6, 'Click') }

  def create
    args = {
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token],
      clickwrap_id: params[:clickwrapId],
      full_name: params[:fullName],
      email: params[:email],
      company: params[:company],
      title: params[:title],
      date: params[:date]
    }

    results = Clickwrap::Eg006EmbedClickwrapService.new(args).worker

    if results.nil?
      @error_code = '200'
      @error_message = 'The email address was already used to agree to this elastic template. Provide a different email address if you want to view the agreement and agree to it.'
      render 'ds_common/error'
    else
      @title = @example['ExampleName']
      @message = format_string(@example['ResultsPageText'])
      @agreementUrl = results['agreementUrl']
      render 'clickwrap/ceg006_embed_clickwrap/results'
    end
  rescue DocuSign_Click::ApiError => e
    handle_error(e)
  end

  def get
    @clickwraps = Clickwrap::Eg006EmbedClickwrapService.new(session).get_active_clickwraps
    @inactive_clickwraps = Clickwrap::Eg006EmbedClickwrapService.new(session).get_inactive_clickwraps
  end
end
