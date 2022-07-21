# frozen_string_literal: true

class Eg001EmbeddedSigningController < EgController
  def create
    begin
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

      pdf_file_path = 'data/World_Wide_Corp_lorem.pdf'

      unless File.exist?(pdf_file_path)
        pdf_file_path = '../data/World_Wide_Corp_lorem.pdf'
      end

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
  end

  def get
    session[:been_here] = true
    super
  end
end
