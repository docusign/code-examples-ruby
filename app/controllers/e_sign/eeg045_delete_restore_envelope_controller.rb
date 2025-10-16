# frozen_string_literal: true

require_relative '../../services/utils'

class ESign::Eeg045DeleteRestoreEnvelopeController < EgController
  before_action -> { check_auth('eSignature') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 45, 'eSignature') }

  DELETE_FOLDER_ID = 'recyclebin'

  def delete_envelope
    args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      envelope_id: param_gsub(params['envelope_id']),
      folder_id: DELETE_FOLDER_ID
    }

    delete_restore_envelope_service = ESign::Eg045DeleteRestoreEnvelopeService.new

    delete_restore_envelope_service.delete_envelope args

    session[:envelope_id] = args[:envelope_id]
    additional_page_data = @example['AdditionalPage'].find { |p| p['Name'] == 'envelope_is_deleted' }
    @title = @example['ExampleName']
    @message = format_string(additional_page_data['ResultsPageText'], args[:envelope_id])
    @redirect_url = "/#{session[:eg]}restore"

    render 'ds_common/example_done'
  end

  def restore_envelope
    folder_name = param_gsub(params['folder_name'])
    args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      envelope_id: param_gsub(session[:envelope_id]),
      from_folder_id: DELETE_FOLDER_ID
    }

    delete_restore_envelope_service = ESign::Eg045DeleteRestoreEnvelopeService.new

    folders = delete_restore_envelope_service.get_folders args
    args[:folder_id] = Utils::DocuSignUtils.new.get_folder_id_by_name(folders.folders, folder_name)

    if args[:folder_id].nil? || args[:folder_id].empty?
      additional_page_data = @example['AdditionalPage'].find { |p| p['Name'] == 'folder_does_not_exist' }
      @title = @example['ExampleName']
      @message = format_string(additional_page_data['ResultsPageText'], folder_name)
      @redirect_url = "/#{session[:eg]}restore"

      return render 'ds_common/example_done'
    end

    delete_restore_envelope_service.move_envelope_to_folder args

    session[:envelope_id] = args[:envelope_id]
    @title = @example['ExampleName']
    @message = format_string(@example['ResultsPageText'], session[:envelope_id], args[:folder_id], folder_name)
    render 'ds_common/example_done'
  end

  def get_delete_envelope
    get
    @envelope_id = session[:envelope_id]
    @submit_button_text = @manifest['SupportingTexts']['HelpingTexts']['SubmitButtonDeleteText']

    render 'e_sign/eeg045_delete_restore_envelope/delete'
  end

  def get_restore_envelope
    return redirect_to "/#{session[:eg]}" if session[:envelope_id].nil?

    get
    @envelope_id = session[:envelope_id]
    @submit_button_text = @manifest['SupportingTexts']['HelpingTexts']['SubmitButtonRestoreText']

    render 'e_sign/eeg045_delete_restore_envelope/restore'
  end
end
