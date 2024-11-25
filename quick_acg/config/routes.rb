require_relative '../../app/controllers/application_controller'
require_relative '../../app/controllers/eg_controller'
require_relative '../../app/controllers/session_controller'
require_relative '../../app/services/api_creator'
require_relative '../../app/controllers/eeg001_embedded_signing_controller'
require_relative '../../app/services/eg001_embedded_signing_service'
require_relative '../../app/services/utils'

class ESign
end

require_relative '../../app/controllers/e_sign/eeg041_cfr_embedded_signing_controller'
require_relative '../../app/services/e_sign/eg041_cfr_embedded_signing_service'
require_relative '../../app/services/e_sign/get_data_service'

Rails.application.routes.draw do
  root 'ds_common#index'

  get '/eeg001' => 'eeg001_embedded_signing#get'
  post '/eeg001' => 'eeg001_embedded_signing#create'

  scope module: 'e_sign' do
    get 'eeg041' => 'eeg041_cfr_embedded_signing#get'
    post 'eeg041' => 'eeg041_cfr_embedded_signing#create'
  end
  # Login starts with POST'ing to: /auth/docusign
  # /auth/docusign is an internal route created by OmniAuth and the docusign strategy from: /lib/docusign.rb
  # Should be POST, see: https://nvd.nist.gov/vuln/detail/CVE-2015-9284
  # get '/ds/login' => redirect('/auth/docusign')

  # Handle OmniAuth OAuth2 login callback result that includes the AuthHash
  get '/auth/:provider/callback', to: 'session#create'

  # Handle OmniAuth OAuth2 login exceptions
  get '/auth/failure', to: 'session#omniauth_failure'

  get '/ds_common-return' => 'ds_common#index'

  get '/ds/mustAuthenticate' => 'ds_common#ds_must_authenticate'
  post '/ds/mustAuthenticate' => 'ds_common#ds_must_authenticate'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
