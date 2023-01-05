# frozen_string_literal: true

class DsCommonController < ApplicationController
  def index
    session[:api] = 'eSignature'
    @show_doc = Rails.application.config.documentation
    handle_redirects
  end
  Rails.configuration.file_watcher
  def handle_redirects
    if session[:quickstarted].nil?
      session[:quickstarted] = true
      redirect_to '/auth/docusign'
    else
      enableCFR = ESign::GetDataService.new(session[:ds_access_token], session[:ds_base_path]).is_cfr(session[:ds_account_id])
      if enableCFR == "enabled"
        session[:status_cfr] = "enabled"
        redirect_to '/eeg041'
      else
        redirect_to '/eeg001'
      end
    end
  end

  def ds_must_authenticate
    redirect_to '/auth/docusign'
  end
end
