require 'bundler/inline'

require 'yaml'
require 'test/unit'
require 'docusign_esign'

$_scopes = %w[
  signature impersonation
]

class TestHelper < Test::Unit::TestCase
  def setup_test_data
    auth_results = authenticate

    @config = get_config_data
    @data = get_common_data

    @account_id = auth_results[:account_id]
    @access_token = auth_results[:access_token]
    @base_path = auth_results[:base_path]
  end

  def authenticate
    ds_config = get_config_data
    data = get_common_data

    configuration = DocuSign_eSign::Configuration.new
    configuration.debugging = true
    api_client = DocuSign_eSign::ApiClient.new(configuration)
    api_client.set_oauth_base_path(data[:authorization_server])

    rsa_pk = './config/docusign_private_key.txt'
    unless File.exist? rsa_pk
      rsa_pk = ENV['PRIVATE_KEY']
    end

    begin
      token = api_client.request_jwt_user_token(ds_config['jwt_integration_key'], ds_config['impersonated_user_guid'], rsa_pk, 3600, $_scopes)
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

  def get_config_data
    config_file_path = './config/appsettings.yml'
    if File.exist? config_file_path
      begin
        config_file_contents = File.read(config_file_path)
      rescue Errno::ENOENT
        warn 'Missing config file'
        raise
      end
      YAML.unsafe_load(config_file_contents)['default']
    else
      config = {}
      config['jwt_integration_key'] = ENV['CLIENT_ID']
      config['impersonated_user_guid'] = ENV['USER_ID']
      config['signer_email'] = ENV['SIGNER_EMAIL']
      config['signer_name'] = ENV['SIGNER_NAME']

      config
    end
  end

  def get_common_data
    {
      cc_name: 'Test Name',
      cc_email: 'test@mail.com',
      authorization_server: 'account-d.docusign.com',
      signer_client_id: 1000,
      ds_ping_url: 'http://localhost:3000',
      ds_return_url: 'http://localhost:3000/ds_common-return',
      doc_docx: './data/World_Wide_Corp_Battle_Plan_Trafalgar.docx',
      doc_pdf: './data/World_Wide_Corp_lorem.pdf',
      doc_for_template: './data/World_Wide_Corp_fields.pdf',
      item: 'Item',
      quantity: 5,
      template_name: 'Example Signer and CC template v2'
    }
  end

  def create_ds_document(filepath_or_content, name, file_ext, doc_id)
    content = File.exist?(filepath_or_content) ? File.binread(filepath_or_content) : filepath_or_content

    document = DocuSign_eSign::Document.new
    document.document_base64 = Base64.encode64(content)
    document.name = name
    document.file_extension = file_ext
    document.document_id = doc_id

    document
  end

  private

  def get_consent
    ds_config = get_config_data

    url_scopes = $_scopes.join('+')
    # Construct consent URL
    redirect_uri = 'https://developers.docusign.com/platform/auth/consent'
    consent_url = "#{ds_config['authorization_server']}/oauth/auth?response_type=code&" \
                "scope=#{url_scopes}&client_id=#{ds_config['jwt_integration_key']}&" \
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
end

class TestData
  @template_id

  def self.get_template_id
    @template_id
  end

  def self.set_template_id(id)
    @template_id = id
  end
end

class ESign
end
