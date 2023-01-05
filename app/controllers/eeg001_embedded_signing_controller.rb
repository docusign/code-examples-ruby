# frozen_string_literal: true

class Eeg001EmbeddedSigningController < EgController
  before_action -> { check_auth('eSignature') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 1) }

  def create
    pdf_file_path = 'data/World_Wide_Corp_lorem.pdf'

    pdf_file_path = '../data/World_Wide_Corp_lorem.pdf' unless File.exist?(pdf_file_path)

    args = {
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token],
      signer_email: param_gsub(params[:signerEmail]),
      signer_name: param_gsub(params[:signerName]),
      ds_ping_url: Rails.application.config.app_url,
      signer_client_id: 1000,
      pdf_filename: pdf_file_path
    }

    redirect_url = Eg001EmbeddedSigningService.new(args).worker
    redirect_to redirect_url
  rescue DocuSign_eSign::ApiError => e
    handle_error(e)
  end

  def get
    enableCFR = ESign::GetDataService.new(session[:ds_access_token], session[:ds_base_path]).is_cfr(session[:ds_account_id])
    if enableCFR == "enabled"
      session[:status_cfr] = "enabled"
      @title = "Not CFR Part 11 compatible"
      @error_information = @manifest['SupportingTexts']['CFRError']
      render 'ds_common/error'
    end
    session[:been_here] = true
    super
  end
end
