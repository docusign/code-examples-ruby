require_relative '../../app/controllers/application_controller'
require_relative '../../app/controllers/eg_controller'
require_relative '../../app/controllers/session_controller'
require_relative '../../app/services/api_creator'
require_relative '../../app/controllers/eg001_embedded_signing_controller'
require_relative '../../app/services/eg001_embedded_signing_service'
require_relative '../../app/services/utils.rb'

Rails.application.routes.draw do
  root 'ds_common#index'

  get '/eg001' => 'eg001_embedded_signing#get'
  post '/eg001' => 'eg001_embedded_signing#create'

  # Login starts with POST'ing to: /auth/docusign
  # /auth/docusign is an internal route created by OmniAuth and the docusign strategy from: /lib/docusign.rb
  # Should be POST, see: https://nvd.nist.gov/vuln/detail/CVE-2015-9284
  # get '/ds/login' => redirect('/auth/docusign')

  # Handle OmniAuth OAuth2 login callback result that includes the AuthHash
  get '/auth/:provider/callback', to: 'session#create'

  get '/ds_common-return' => 'ds_common#index'

  get '/ds/mustAuthenticate' => 'ds_common#ds_must_authenticate'
  post '/ds/mustAuthenticate' => 'ds_common#ds_must_authenticate'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
