# frozen_string_literal: true

class ESign::Eeg045DeleteRestoreEnvelopeController < EgController
  before_action -> { check_auth('eSignature') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 45, 'eSignature') }

  DELETE_FOLDER_ID = 'recyclebin'
  RESTORE_FOLDER_ID = 'sentitems'

  def delete_envelope
    args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      envelope_id: param_gsub(params['envelope_id']),
      folder_id: DELETE_FOLDER_ID
    }

    delete_restore_envelope_service = ESign::Eg045DeleteRestoreEnvelopeService.new(args)

    delete_restore_envelope_service.move_envelope

    session[:envelope_id] = args[:envelope_id]
    additional_page_data = @example['AdditionalPage'].find { |p| p['Name'] == 'envelope_is_deleted' }
    @title = @example['ExampleName']
    @message = additional_page_data['ResultsPageText']
    @redirect_url = "/#{session[:eg]}restore"

    render 'ds_common/example_done'
  end

  def restore_envelope
    args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token'],
      envelope_id: param_gsub(session[:envelope_id]),
      folder_id: RESTORE_FOLDER_ID,
      from_folder_id: DELETE_FOLDER_ID
    }

    delete_restore_envelope_service = ESign::Eg045DeleteRestoreEnvelopeService.new(args)

    delete_restore_envelope_service.move_envelope

    session[:envelope_id] = args[:envelope_id]
    @title = @example['ExampleName']
    @message = @example['ResultsPageText']
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
