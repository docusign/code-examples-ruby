Rails.application.routes.draw do

  root 'ds_common#index'

  # login starts with /ds_common/login
  # /auth/docusign is an internal route created by omniauth and the docusign strategy.
  # The docusign strategy file is /lib/docusign
  get '/ds/login' => redirect('/auth/docusign')
  # Next, the oauth callback is handled by session#create in /app/controllers/session_controller
  get '/auth/:provider/callback', to: 'session#create'

  # Logout
  get '/ds/logout', to: 'session#destroy'

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

  get '/ds_common-return' => 'ds_common#ds_return'
  get '/ds/mustAuthenticate' => 'ds_common#ds_must_authenticate'

  # default root
  get 'ds_common/index'
  get 'example_done' => 'ds_common#example_done'
  get 'error' => 'ds_common#error'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
