# frozen_string_literal: true

require_relative '../../services/utils'

class ESign::Eg041CfrEmbeddedSigningController < EgController
  before_action :check_auth
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 41) }

  def create
    pdf_file_path = 'data/World_Wide_Corp_lorem.pdf'

    pdf_file_path = '../data/World_Wide_Corp_lorem.pdf' unless File.exist?(pdf_file_path)

    envelope_args = {
      signer_email: param_gsub(params['signerEmail']),
      signer_name: param_gsub(params['signerName']),
      country_code: param_gsub(params['countryCode']),
      phone_number: param_gsub(params['phoneNumber']),
      signer_client_id: 1000,
      ds_return_url: "#{Rails.application.config.app_url}/ds_common-return",
      ds_ping_url: "#{Rails.application.config.app_url}/",
      pdf_filename: pdf_file_path
    }
    args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      envelope_args: envelope_args
    }
    redirect_url = ESign::Eg041CfrEmbeddedSigningService.new(args).worker

    if redirect_url.to_s == 'invalid_workflow_id'
      @error_code = 'IDENTITY_WORKFLOW_INVALID_ID'
      @error_message = 'The identity workflow ID specified is not valid.'
      render 'ds_common/error'
    else
      redirect_to redirect_url
    end
  rescue DocuSign_eSign::ApiError => e
    handle_error(e)
  end

  def get
    enableCFR = ESign::GetDataService.new(session[:ds_access_token], session[:ds_base_path]).is_cfr(session[:ds_account_id])
    if enableCFR != "enabled"
      @title = "Must use a CFR Part 11 enabled account"
      @error_information = "This example requires a CFR Part 11 account. Please return to the homepage to run one of the examples that is compatible or authenticate with a different account."
      render 'ds_common/error'
    end
    super
  end
end
