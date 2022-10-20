module Utils
  class ManifestUtils
    def get_manifest(manifest_url)
      uri = URI(manifest_url)
      res = Net::HTTP.get_response(uri)
      JSON.parse(res.body)
    end

    def get_example(manifest, number)
      manifest['Groups'].each do |group|
        group['Examples'].each do |example|
          return example if example['ExampleNumber'] == number
        end
      end
    end
  end
end
