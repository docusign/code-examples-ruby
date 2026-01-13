# frozen_string_literal: true

class AdminApi::Eg012CloneAccountService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:Admin12Step2
    configuration = DocuSign_Admin::Configuration.new
    configuration.host = Rails.configuration.admin_host

    api_client = DocuSign_Admin::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    #ds-snippet-end:Admin12Step2

    #ds-snippet-start:Admin12Step4
    source_account = DocuSign_Admin::AssetGroupAccountCloneSourceAccount.new
    source_account.id = args[:source_account_id]

    target_account_admin = DocuSign_Admin::AssetGroupAccountCloneTargetAccountAdmin.new
    target_account_admin.first_name = args[:target_account_first_name]
    target_account_admin.last_name = args[:target_account_last_name]
    target_account_admin.email = args[:target_account_email]

    target_account = DocuSign_Admin::AssetGroupAccountCloneTargetAccount.new
    target_account.name = args[:target_account_name]
    target_account.admin = target_account_admin
    target_account.country_code = 'US'

    account_data = DocuSign_Admin::AssetGroupAccountClone.new
    account_data.source_account = source_account
    account_data.target_account = target_account
    #ds-snippet-end:Admin12Step4

    #ds-snippet-start:Admin12Step5
    asset_group_api = DocuSign_Admin::ProvisionAssetGroupApi.new(api_client)
    results, _status, headers = asset_group_api.clone_asset_group_account_with_http_info(args[:organization_id], account_data)

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:Admin12Step5

    results
  end

  def get_account
    configuration = DocuSign_Admin::Configuration.new
    configuration.host = Rails.configuration.admin_host

    api_client = DocuSign_Admin::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")

    #ds-snippet-start:Admin12Step3
    asset_group_api = DocuSign_Admin::ProvisionAssetGroupApi.new(api_client)
    options = DocuSign_Admin::GetAssetGroupAccountsOptions.new
    options.compliant = true
    results, _status, headers = asset_group_api.get_asset_group_accounts_with_http_info(args[:organization_id], options)

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:Admin12Step3

    results
  end
end
