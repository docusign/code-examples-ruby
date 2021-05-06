# frozen_string_literal: true

Rails.application.routes.draw do
  if Rails.configuration.examples_API['Rooms']
    scope module: 'room_api' do
      get 'eg001' => 'eg001_create_room_with_data#get'
      post 'eg001' => 'eg001_create_room_with_data#create'

      get 'eg002' => 'eg002_create_room_with_template#get'
      post 'eg002' => 'eg002_create_room_with_template#create'

      get 'eg003' => 'eg003_export_data_from_room#get'
      post 'eg003' => 'eg003_export_data_from_room#create'

      get 'eg004' => 'eg004_add_forms_to_room#get'
      post 'eg004' => 'eg004_add_forms_to_room#create'

      get 'eg005' => 'eg005_get_rooms_with_filters#get'
      post 'eg005' => 'eg005_get_rooms_with_filters#create'

      get 'eg006' => 'eg006_create_an_external_form_fill_session#get_rooms'
      get 'eg006_forms' => 'eg006_create_an_external_form_fill_session#get_forms'
      post 'eg006' => 'eg006_create_an_external_form_fill_session#create'

      get 'eg007' => 'eg007_create_form_group#get'
      post 'eg007' => 'eg007_create_form_group#create'

      get 'eg008' => 'eg008_grant_office_access_to_form_group#get'
      post 'eg008' => 'eg008_grant_office_access_to_form_group#create'

      get 'eg009' => 'eg009_assign_form_to_form_group#get'
      post 'eg009' => 'eg009_assign_form_to_form_group#create'
    end
  elsif Rails.configuration.examples_API['Click']
    scope module: 'clickwrap' do
      get 'eg001' => 'eg001_create_clickwrap#get'
      post 'eg001' => 'eg001_create_clickwrap#create'

      get 'eg002' => 'eg002_activate_clickwrap#get'
      post 'eg002' => 'eg002_activate_clickwrap#create'

      get 'eg003' => 'eg003_create_new_clickwrap_version#get'
      post 'eg003' => 'eg003_create_new_clickwrap_version#create'

      get 'eg004' => 'eg004_list_clickwraps#get'
      post 'eg004' => 'eg004_list_clickwraps#create'

      get 'eg005' => 'eg005_clickwrap_responses#get'
      post 'eg005' => 'eg005_clickwrap_responses#create'
    end
  elsif Rails.configuration.examples_API['Monitor']
    scope module: 'monitor_api' do
      get 'eg001' => 'eg001_get_monitoring_dataset#get'
      post 'eg001' => 'eg001_get_monitoring_dataset#create'
    end
  else
    scope module: 'e_sign' do
      # Example controllers...
      get 'eg001' => 'eg001_embedded_signing#get'
      post 'eg001' => 'eg001_embedded_signing#create'

      get 'eg002' => 'eg002_signing_via_email#get'
      post 'eg002' => 'eg002_signing_via_email#create'

      get 'eg003' => 'eg003_list_envelopes#get'
      post 'eg003' => 'eg003_list_envelopes#create'

      get 'eg004' => 'eg004_envelope_info#get'
      post 'eg004' => 'eg004_envelope_info#create'

      get 'eg005' => 'eg005_envelope_recipients#get'
      post 'eg005' => 'eg005_envelope_recipients#create'

      get 'eg006' => 'eg006_envelope_docs#get'
      post 'eg006' => 'eg006_envelope_docs#create'

      get 'eg007' => 'eg007_envelope_get_doc#get'
      post 'eg007' => 'eg007_envelope_get_doc#create'

      get 'eg008' => 'eg008_create_template#get'
      post 'eg008' => 'eg008_create_template#create'

      get 'eg009' => 'eg009_use_template#get'
      post 'eg009' => 'eg009_use_template#create'

      get 'eg010' => 'eg010_send_binary_docs#get'
      post 'eg010' => 'eg010_send_binary_docs#create'

      get 'eg011' => 'eg011_embedded_sending#get'
      post 'eg011' => 'eg011_embedded_sending#create'

      get 'eg012' => 'eg012_embedded_console#get'
      post 'eg012' => 'eg012_embedded_console#create'

      get 'eg013' => 'eg013_add_doc_to_template#get'
      post 'eg013' => 'eg013_add_doc_to_template#create'

      get 'eg014' => 'eg014_collect_payment#get'
      post 'eg014' => 'eg014_collect_payment#create'

      get 'eg015' => 'eg015_get_envelope_tab_data#get'
      post 'eg015' => 'eg015_get_envelope_tab_data#create'

      get 'eg016' => 'eg016_set_envelope_tab_data#get'
      post 'eg016' => 'eg016_set_envelope_tab_data#create'

      get 'eg017' => 'eg017_set_template_tab_values#get'
      post 'eg017' => 'eg017_set_template_tab_values#create'

      get 'eg018' => 'eg018_get_envelope_custom_field_data#get'
      post 'eg018' => 'eg018_get_envelope_custom_field_data#create'

      get 'eg019' => 'eg019_access_code_authentication#get'
      post 'eg019' => 'eg019_access_code_authentication#create'

      get 'eg020' => 'eg020_sms_authentication#get'
      post 'eg020' => 'eg020_sms_authentication#create'

      get 'eg021' => 'eg021_phone_authentication#get'
      post 'eg021' => 'eg021_phone_authentication#create'

      get 'eg022' => 'eg022_kba_authentication#get'
      post 'eg022' => 'eg022_kba_authentication#create'

      get 'eg023' => 'eg023_idv_authentication#get'
      post 'eg023' => 'eg023_idv_authentication#create'

      get 'eg024' => 'eg024_permission_create#get'
      post 'eg024' => 'eg024_permission_create#create'

      get 'eg025' => 'eg025_permissions_set_user_group#get'
      post 'eg025' => 'eg025_permissions_set_user_group#create'

      get 'eg026' => 'eg026_permissions_change_single_setting#get'
      post 'eg026' => 'eg026_permissions_change_single_setting#create'

      get 'eg027' => 'eg027_permissions_delete#get'
      post 'eg027' => 'eg027_permissions_delete#create'

      get 'eg028' => 'eg028_brands_creating#get'
      post 'eg028' => 'eg028_brands_creating#create'

      get 'eg029' => 'eg029_brands_apply_to_envelope#get'
      post 'eg029' => 'eg029_brands_apply_to_envelope#create'

      get 'eg030' => 'eg030_brands_apply_to_template#get'
      post 'eg030' => 'eg030_brands_apply_to_template#create'

      get 'eg031' => 'eg031_bulk_sending_envelopes#get'
      post 'eg031' => 'eg031_bulk_sending_envelopes#create'

      get 'eg032' => 'eg032_pauses_signature_workflow#get'
      post 'eg032' => 'eg032_pauses_signature_workflow#create'

      get 'eg033' => 'eg033_unpauses_signature_workflow#get'
      put 'eg033' => 'eg033_unpauses_signature_workflow#update'

      get 'eg034' => 'eg034_use_conditional_recipients#get'
      post 'eg034' => 'eg034_use_conditional_recipients#create'

      get 'eg035' => 'eg035_sms_delivery#get'
      post 'eg035' => 'eg035_sms_delivery#create'
    end
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
