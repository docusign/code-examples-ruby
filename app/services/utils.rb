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

    def get_folder_id_by_name(folders, folder_name)
      folders.each do |folder|
        return folder.folder_id if folder.name.downcase == folder_name.downcase

        if folder.folders&.any?
          folder_id = get_folder_id_by_name(folder.folders, folder_name)
          return folder_id if folder_id
        end
      end

      nil
    end
  end

  class FileUtils
    def replace_template_id(file_path, template_id)
      content = File.read(file_path)

      content.gsub!('template-id', template_id)

      File.write(file_path, content)
    end
  end

  class URLUtils
    def get_parameter_value_from_url(url, param_name)
      parsed_url = URI.parse(url)
      query_params = URI.decode_www_form(parsed_url.query || '')

      # Access the parameter value (returns a list)
      param_value_list = query_params.assoc(param_name)

      # If the parameter exists, return the first value; otherwise, return nil
      param_value_list ? param_value_list[1] : nil
    end
  end
end
