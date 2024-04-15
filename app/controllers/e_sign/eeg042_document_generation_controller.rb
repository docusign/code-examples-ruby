# frozen_string_literal: true

require_relative '../../services/utils'

class ESign::Eeg042DocumentGenerationController < EgController
  before_action -> { check_auth('eSignature') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 42, 'eSignature') }

  def create
    envelope_args = {
      candidate_email: param_gsub(params['candidate_email']),
      candidate_name: param_gsub(params['candidate_name']),
      manager_name: param_gsub(params['manager_name']),
      job_title: param_gsub(params['job_title']),
      salary: param_gsub(params['salary']),
      rsus: param_gsub(params['rsus']),
      start_date: param_gsub(params['start_date']),
      doc_file: File.join('data', Rails.application.config.offer_letter_dynamic_table)
    }
    args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      envelope_args: envelope_args
    }
    results = ESign::Eg042DocumentGenerationService.new(args).worker
    session[:envelope_id] = results['envelope_id']
    @title = @example['ExampleName']
    @message = format_string(@example['ResultsPageText'], results['envelope_id'])
    render 'ds_common/example_done'
  rescue DocuSign_eSign::ApiError => e
    handle_error(e)
  end
end
