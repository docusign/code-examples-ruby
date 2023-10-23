# frozen_string_literal: true

class ESign::Eeg044FocusedViewController < EgController
  before_action -> { check_auth('eSignature') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 44) }

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

    @integration_key = Rails.application.config.integration_key
    @url = ESign::Eg044FocusedViewService.new(args).worker
    render 'e_sign/eeg044_focused_view/embed'
  rescue DocuSign_eSign::ApiError => e
    handle_error(e)
  end
end
