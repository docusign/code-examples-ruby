# frozen_string_literal: true

Rails.application.routes.draw do
  scope module: 'room_api' do
    get 'reg001' => 'reg001_create_room_with_data#get'
    post 'reg001' => 'reg001_create_room_with_data#create'

    get 'reg002' => 'reg002_create_room_with_template#get'
    post 'reg002' => 'reg002_create_room_with_template#create'

    get 'reg003' => 'reg003_export_data_from_room#get'
    post 'reg003' => 'reg003_export_data_from_room#create'

    get 'reg004' => 'reg004_add_forms_to_room#get'
    post 'reg004' => 'reg004_add_forms_to_room#create'

    get 'reg005' => 'reg005_get_rooms_with_filters#get'
    post 'reg005' => 'reg005_get_rooms_with_filters#create'

    get 'reg006' => 'reg006_create_an_external_form_fill_session#get_rooms'
    get 'reg006_forms' => 'reg006_create_an_external_form_fill_session#get_forms'
    post 'reg006' => 'reg006_create_an_external_form_fill_session#create'

    get 'reg007' => 'reg007_create_form_group#get'
    post 'reg007' => 'reg007_create_form_group#create'

    get 'reg008' => 'reg008_grant_office_access_to_form_group#get'
    post 'reg008' => 'reg008_grant_office_access_to_form_group#create'

    get 'reg009' => 'reg009_assign_form_to_form_group#get'
    post 'reg009' => 'reg009_assign_form_to_form_group#create'
  end

  scope module: 'clickwrap' do
    get 'ceg001' => 'ceg001_create_clickwrap#get'
    post 'ceg001' => 'ceg001_create_clickwrap#create'

    get 'ceg002' => 'ceg002_activate_clickwrap#get'
    post 'ceg002' => 'ceg002_activate_clickwrap#create'

    get 'ceg003' => 'ceg003_create_new_clickwrap_version#get'
    post 'ceg003' => 'ceg003_create_new_clickwrap_version#create'

    get 'ceg004' => 'ceg004_list_clickwraps#get'
    post 'ceg004' => 'ceg004_list_clickwraps#create'

    get 'ceg005' => 'ceg005_clickwrap_responses#get'
    post 'ceg005' => 'ceg005_clickwrap_responses#create'

    get 'ceg006' => 'ceg006_embed_clickwrap#get'
    post 'ceg006' => 'ceg006_embed_clickwrap#create'
  end

  scope module: 'monitor_api' do
    get 'meg001' => 'meg001_get_monitoring_dataset#get'
    post 'meg001' => 'meg001_get_monitoring_dataset#create'
    get 'meg002' => 'meg002_post_web_query#get'
    post 'meg002' => 'meg002_post_web_query#create'
  end

  scope module: 'admin_api' do
    get 'aeg001' => 'aeg001_create_user#get'
    post 'aeg001' => 'aeg001_create_user#create'

    get 'aeg002' => 'aeg002_create_active_clm_esign_user#get'
    post 'aeg002' => 'aeg002_create_active_clm_esign_user#create'

    get 'aeg003' => 'aeg003_bulk_export_user_data#get'
    post 'aeg003' => 'aeg003_bulk_export_user_data#create'

    get 'aeg004' => 'aeg004_import_user#get'
    post 'aeg004' => 'aeg004_import_user#create'
    get 'aeg004status' => 'aeg004_import_user#check_status'

    get 'aeg005' => 'aeg005_audit_users#get'
    post 'aeg005' => 'aeg005_audit_users#create'

    get 'aeg006' => 'aeg006_get_user_profile_by_email#get'
    post 'aeg006' => 'aeg006_get_user_profile_by_email#create'

    get 'aeg007' => 'aeg007_get_user_profile_by_user_id#get'
    post 'aeg007' => 'aeg007_get_user_profile_by_user_id#create'

    get 'aeg008' => 'aeg008_update_user_product_permission_profile#get'
    post 'aeg008' => 'aeg008_update_user_product_permission_profile#create'

    get 'aeg009' => 'aeg009_delete_user_product_permission_profile#get'
    post 'aeg009' => 'aeg009_delete_user_product_permission_profile#create'
  end

  get '/eeg001' => 'eeg001_embedded_signing#get'
  post '/eeg001' => 'eeg001_embedded_signing#create'

  scope module: 'e_sign' do
    # Example controllers...
    get 'eeg002' => 'eeg002_signing_via_email#get'
    post 'eeg002' => 'eeg002_signing_via_email#create'

    get 'eeg003' => 'eeg003_list_envelopes#get'
    post 'eeg003' => 'eeg003_list_envelopes#create'

    get 'eeg004' => 'eeg004_envelope_info#get'
    post 'eeg004' => 'eeg004_envelope_info#create'

    get 'eeg005' => 'eeg005_envelope_recipients#get'
    post 'eeg005' => 'eeg005_envelope_recipients#create'

    get 'eeg006' => 'eeg006_envelope_docs#get'
    post 'eeg006' => 'eeg006_envelope_docs#create'

    get 'eeg007' => 'eeg007_envelope_get_doc#get'
    post 'eeg007' => 'eeg007_envelope_get_doc#create'

    get 'eeg008' => 'eeg008_create_template#get'
    post 'eeg008' => 'eeg008_create_template#create'

    get 'eeg009' => 'eeg009_use_template#get'
    post 'eeg009' => 'eeg009_use_template#create'

    get 'eeg010' => 'eeg010_send_binary_docs#get'
    post 'eeg010' => 'eeg010_send_binary_docs#create'

    get 'eeg011' => 'eeg011_embedded_sending#get'
    post 'eeg011' => 'eeg011_embedded_sending#create'

    get 'eeg012' => 'eeg012_embedded_console#get'
    post 'eeg012' => 'eeg012_embedded_console#create'

    get 'eeg013' => 'eeg013_add_doc_to_template#get'
    post 'eeg013' => 'eeg013_add_doc_to_template#create'

    get 'eeg014' => 'eeg014_collect_payment#get'
    post 'eeg014' => 'eeg014_collect_payment#create'

    get 'eeg015' => 'eeg015_get_envelope_tab_data#get'
    post 'eeg015' => 'eeg015_get_envelope_tab_data#create'

    get 'eeg016' => 'eeg016_set_envelope_tab_data#get'
    post 'eeg016' => 'eeg016_set_envelope_tab_data#create'

    get 'eeg017' => 'eeg017_set_template_tab_values#get'
    post 'eeg017' => 'eeg017_set_template_tab_values#create'

    get 'eeg018' => 'eeg018_get_envelope_custom_field_data#get'
    post 'eeg018' => 'eeg018_get_envelope_custom_field_data#create'

    get 'eeg019' => 'eeg019_access_code_authentication#get'
    post 'eeg019' => 'eeg019_access_code_authentication#create'

    get 'eeg020' => 'eeg020_phone_authentication#get'
    post 'eeg020' => 'eeg020_phone_authentication#create'

    get 'eeg022' => 'eeg022_kba_authentication#get'
    post 'eeg022' => 'eeg022_kba_authentication#create'

    get 'eeg023' => 'eeg023_idv_authentication#get'
    post 'eeg023' => 'eeg023_idv_authentication#create'

    get 'eeg024' => 'eeg024_permission_create#get'
    post 'eeg024' => 'eeg024_permission_create#create'

    get 'eeg025' => 'eeg025_permissions_set_user_group#get'
    post 'eeg025' => 'eeg025_permissions_set_user_group#create'

    get 'eeg026' => 'eeg026_permissions_change_single_setting#get'
    post 'eeg026' => 'eeg026_permissions_change_single_setting#create'

    get 'eeg027' => 'eeg027_permissions_delete#get'
    post 'eeg027' => 'eeg027_permissions_delete#create'

    get 'eeg028' => 'eeg028_brands_creating#get'
    post 'eeg028' => 'eeg028_brands_creating#create'

    get 'eeg029' => 'eeg029_brands_apply_to_envelope#get'
    post 'eeg029' => 'eeg029_brands_apply_to_envelope#create'

    get 'eeg030' => 'eeg030_brands_apply_to_template#get'
    post 'eeg030' => 'eeg030_brands_apply_to_template#create'

    get 'eeg031' => 'eeg031_bulk_sending_envelopes#get'
    post 'eeg031' => 'eeg031_bulk_sending_envelopes#create'

    get 'eeg032' => 'eeg032_pauses_signature_workflow#get'
    post 'eeg032' => 'eeg032_pauses_signature_workflow#create'

    get 'eeg033' => 'eeg033_unpauses_signature_workflow#get'
    put 'eeg033' => 'eeg033_unpauses_signature_workflow#update'

    get 'eeg034' => 'eeg034_use_conditional_recipients#get'
    post 'eeg034' => 'eeg034_use_conditional_recipients#create'

    get 'eeg035' => 'eeg035_scheduled_sending#get'
    post 'eeg035' => 'eeg035_scheduled_sending#create'

    get 'eeg036' => 'eeg036_delayed_routing#get'
    post 'eeg036' => 'eeg036_delayed_routing#create'

    get 'eeg037' => 'eeg037_sms_delivery#get'
    post 'eeg037' => 'eeg037_sms_delivery#create'

    get 'eeg038' => 'eeg038_responsive_signing#get'
    post 'eeg038' => 'eeg038_responsive_signing#create'

    get 'eeg039' => 'eeg039_signing_in_person#get'
    post 'eeg039' => 'eeg039_signing_in_person#create'

    get 'eeg040' => 'eeg040_set_document_visibility#get'
    post 'eeg040' => 'eeg040_set_document_visibility#create'

    get 'eeg041' => 'eeg041_cfr_embedded_signing#get'
    post 'eeg041' => 'eeg041_cfr_embedded_signing#create'

    get 'eeg042' => 'eeg042_document_generation#get'
    post 'eeg042' => 'eeg042_document_generation#create'
  end

  root 'ds_common#index'

  # Login starts with POST'ing to: /auth/docusign
  # /auth/docusign is an internal route created by OmniAuth and the docusign strategy from: /lib/docusign.rb
  # Should be POST, see: https://nvd.nist.gov/vuln/detail/CVE-2015-9284
  # get '/ds/login' => redirect('/auth/docusign')

  # Handle OmniAuth OAuth2 login callback result that includes the AuthHash
  get '/auth/:provider/callback', to: 'session#create'

  # Handle OmniAuth OAuth2 login exceptions in non development environments:
  get '/auth/failure', to: 'session#omniauth_failure'

  # Logout
  get '/ds/logout', to: 'session#destroy'

  get '/ds_common-return' => 'ds_common#ds_return'
  get '/ds/mustAuthenticate' => 'ds_common#ds_must_authenticate'
  post '/ds/mustAuthenticate' => 'ds_common#ds_must_authenticate'
  get '/ds/mustAuthenticateJwt' => 'ds_common#ds_must_authenticate_jwt'
  post '/ds/mustAuthenticateJwt' => 'ds_common#ds_must_authenticate'

  get '/ds/session' => 'session#show'
  # default root

  get 'ds_common/index'
  get 'example_done' => 'ds_common#example_done'
  get 'error' => 'ds_common#error'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
