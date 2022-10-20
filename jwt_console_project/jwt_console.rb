require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'docusign_esign', ' ~> 3.17.0'
end

class ESign
end

require 'docusign_esign'
require_relative '../app/services/api_creator'
require_relative '../app/services/e_sign/eg002_signing_via_email_service'
require 'yaml'

$SCOPES = %w[
  signature impersonation
]

def load_config_data
  config_file_path = 'jwt_config.yml'
  begin
    config_file_contents = File.read(config_file_path)
  rescue Errno::ENOENT
    warn 'Missing config file'
    raise
  end
  YAML.unsafe_load(config_file_contents)
end

def get_consent
  url_scopes = $SCOPES.join('+')
  # Construct consent URL
  redirect_uri = 'https://developers.docusign.com/platform/auth/consent'
  consent_url = "https://#{CONFIG['authorization_server']}/oauth/auth?response_type=code&" \
                "scope=#{url_scopes}&client_id=#{CONFIG['jwt_integration_key']}&" \
                "redirect_uri=#{redirect_uri}"

  puts 'Open the following URL in your browser to grant consent to the application:'
  puts consent_url
  puts "Consent granted? \n 1)Yes \n 2)No"
  continue = gets
  if continue.chomp == '1'
    true
  else
    puts 'Please grant consent'
    exit
  end
end

def authenticate
  configuration = DocuSign_eSign::Configuration.new
  configuration.debugging = true
  api_client = DocuSign_eSign::ApiClient.new(configuration)
  api_client.set_oauth_base_path(CONFIG['authorization_server'])

  rsa_pk = 'docusign_private_key.txt'
  begin
    token = api_client.request_jwt_user_token(CONFIG['jwt_integration_key'], CONFIG['impersonated_user_guid'], rsa_pk, 3600, $SCOPES)
    user_info_response = api_client.get_user_info(token.access_token)
    account = user_info_response.accounts.find(&:is_default)

    {
      access_token: token.access_token,
      account_id: account.account_id,
      base_path: account.base_uri
    }
  rescue OpenSSL::PKey::RSAError => e
    Rails.logger.error e.inspect

    raise "Please add your private RSA key to: #{rsa_pk}" if File.read(rsa_pk).starts_with? '{RSA_PRIVATE_KEY}'

    raise
  rescue DocuSign_eSign::ApiError => e
    body = JSON.parse(e.response_body)
    if body['error'] == 'consent_required'
      authenticate if get_consent
    else
      puts 'API Error'
      puts body['error']
      puts body['message']
      exit
    end
  end
end

def get_args(apiAccountId, accessToken, basePath)
  puts "Enter the signer's email address: "
  signerEmail = gets.chomp
  puts "Enter the signer's name: "
  signerName = gets.chomp
  puts "Enter the carbon copy's email address: "
  ccSignerEmail = gets.chomp
  puts "Enter the carbon copy's name: "
  ccSignerName = gets.chomp

  envelope_args = {
    signer_email: signerEmail,
    signer_name: signerName,
    cc_email: ccSignerEmail,
    cc_name: ccSignerName,
    status: 'sent',
    doc_docx: '../data/World_Wide_Corp_Battle_Plan_Trafalgar.docx',
    doc_pdf: '../data/World_Wide_Corp_lorem.pdf'
  }
  {
    account_id: apiAccountId,
    base_path: basePath,
    access_token: accessToken,
    envelope_args: envelope_args
  }
end

def main
  load_config_data
  account_info = authenticate
  args = get_args(account_info[:account_id], account_info[:access_token], account_info[:base_path])
  results = ESign::Eg002SigningViaEmailService.new(args).worker
  puts "Successfully sent envelope with envelope ID: #{results['envelope_id']}"
end

CONFIG = load_config_data
main
