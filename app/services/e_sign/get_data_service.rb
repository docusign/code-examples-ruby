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
    raise 'The user does not have access to account' unless user_info

    user_info.email
  end

  def get_current_user_name
    worker

    user_info = @api_client.get_user_info(args[:access_token])
    raise 'The user does not have access to account' unless user_info

    user_info.name
  end

  def is_cfr(account_id)
    worker
    accounts_api = DocuSign_eSign::AccountsApi.new @api_client
    account_details = accounts_api.get_account_information(account_id)
    account_details.status21_cfr_part11
  end

  private

  def worker
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:base_path]

    @api_client = DocuSign_eSign::ApiClient.new(configuration)
    @api_client.set_base_path(args[:base_path])
    @api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
  end
end
