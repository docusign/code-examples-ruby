# frozen_string_literal: true

class ESign::Eeg039SigningInPersonController < EgController
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 39, 'eSignature') }

  def create
    minimum_buffer_min = 10
    token_ok = check_token(minimum_buffer_min)
    unless token_ok
      flash[:messages] = 'Sorry, you need to re-authenticate.'
      # We could store the parameters of the requested operation
      # so it could be restarted automatically.
      # But since it should be rare to have a token issue here,
      # we'll make the user re-enter the form data after
      # authentication.
      return redirect_to '/ds/mustAuthenticate'
    end

    access_token = session[:ds_access_token]
    base_path = session[:ds_base_path]
    email = ESign::GetDataService.new(access_token, base_path).get_current_user_email
    name = ESign::GetDataService.new(access_token, base_path).get_current_user_name

    args = {
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token],
      host_email: param_gsub(email),
      host_name: param_gsub(name),
      signer_name: param_gsub(params[:signer_name]),
      ds_ping_url: Rails.application.config.app_url,
      pdf_filename: 'data/World_Wide_Corp_lorem.pdf'
    }

    redirect_url = ESign::Eg039SigningInPersonService.new(args).worker
    redirect_to redirect_url
  end

  def get
    enableCFR = ESign::GetDataService.new(session[:ds_access_token], session[:ds_base_path]).cfr?(session[:ds_account_id])
    if enableCFR == 'enabled'
      session[:status_cfr] = 'enabled'
      @title = 'Not CFR Part 11 compatible'
      @error_information = @manifest['SupportingTexts']['CFRError']
      render 'ds_common/error'
    end
    super
  end
end
