module Utils
  class ManifestUtils
    def get_manifest(manifest_url)
      uri = URI(manifest_url)
      res = Net::HTTP.get_response(uri)
      JSON.parse(res.body)
    end

    def get_example(manifest, number, api_name = 'eSignature')
      manifest['APIs'].each do |api|
        next unless api_name == api['Name']

        api['Groups'].each do |group|
          group['Examples'].each do |example|
            return example if example['ExampleNumber'] == number
          end
        end
      end
    end
  end

  class DocuSignUtils
    def get_user_id(args)
      configuration = DocuSign_eSign::Configuration.new
      configuration.host = args[:base_path]
      api_client = DocuSign_eSign::ApiClient.new configuration
      api_client.set_base_path(args[:base_path])
      api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
      user_info = api_client.get_user_info(args[:access_token])
      user_info.sub
    end
  end
end
