class ESign::GetDataService
  attr_reader :args

  def initialize(access_token, base_path)
    @args = {
      access_token: access_token,
      base_path: base_path
    }
  end

  def get_current_user_email
    worker

    user_info = @api_client.get_user_info(args[:access_token])
    unless user_info
      raise "The user does not have access to account"
    end

    user_info.email
  end

  def get_current_user_name
    worker

    user_info = @api_client.get_user_info(args[:access_token])
    unless user_info
      raise "The user does not have access to account"
    end

    user_info.name
  end

  private

  def worker
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:base_path]

    @api_client = DocuSign_eSign::ApiClient.new(configuration)
    @api_client.set_base_path(args[:base_path])
    @api_client.set_default_header("Authorization", "Bearer #{args[:access_token]}")

  end
end