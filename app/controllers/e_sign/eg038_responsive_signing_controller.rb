# frozen_string_literal: true

class ESign::Eg038ResponsiveSigningController < EgController
  before_action :check_auth

  def create
    begin
      args = {
        account_id: session[:ds_account_id],
        base_path: session[:ds_base_path],
        access_token: session[:ds_access_token],
        signer_email: param_gsub(params[:signerEmail]),
        signer_name: param_gsub(params[:signerName]),
        cc_email: param_gsub(params[:ccEmail]),
        cc_name: param_gsub(params[:ccName]),
        ds_ping_url: Rails.application.config.app_url,
        signer_client_id: 1000,
        doc_file: 'data/order_form.html'
      }

      redirect_url = ESign::Eg038ResponsiveSigningService.new(args).worker
      redirect_to redirect_url
    rescue DocuSign_eSign::ApiError => e
      handle_error(e)
    end
  end
end
