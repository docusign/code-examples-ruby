# frozen_string_literal: true

class DsCommonController < ApplicationController
  def index
    @show_doc = Rails.application.config.documentation
    handle_redirects
  end
  Rails.configuration.file_watcher
  def handle_redirects
    if session[:quickstarted].nil?
      session[:quickstarted] = true
      redirect_to "/auth/docusign"
    else
      redirect_to '/eg001'
    end
  end

  def ds_must_authenticate
    redirect_to "/auth/docusign"
  end
end
