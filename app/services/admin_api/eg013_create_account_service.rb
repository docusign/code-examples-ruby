# frozen_string_literal: true

class AdminApi::Eg013CreateAccountService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:Admin13Step2
    configuration = DocuSign_Admin::Configuration.new
    configuration.host = Rails.configuration.admin_host

    api_client = DocuSign_Admin::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    #ds-snippet-end:Admin13Step2

    #ds-snippet-start:Admin13Step4
    target_account_admin = DocuSign_Admin::SubAccountCreateRequestSubAccountCreationTargetAccountAdmin.new
    target_account_admin.first_name = args[:first_name]
    target_account_admin.last_name = args[:last_name]
    target_account_admin.email = args[:email]
    target_account_admin.locale = 'en'

    target_account = DocuSign_Admin::SubAccountCreateRequestSubAccountCreationTargetAccountDetails.new
    target_account.name = 'CreatedThroughAPI'
    target_account.admin = target_account_admin
    target_account.country_code = 'US'

    subscription_details = DocuSign_Admin::SubAccountCreateRequestSubAccountCreationSubscription.new
    subscription_details.id = args[:subscription_id]
    subscription_details.plan_id = args[:plan_id]
    subscription_details.modules = []

    account_data = DocuSign_Admin::SubAccountCreateRequest.new
    account_data.subscription_details = subscription_details
    account_data.target_account = target_account
    #ds-snippet-end:Admin13Step4

    #ds-snippet-start:Admin13Step5
    asset_group_api = DocuSign_Admin::ProvisionAssetGroupApi.new(api_client)
    results, _status, headers = asset_group_api.create_asset_group_account_with_http_info(args[:organization_id], account_data)

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:Admin13Step5

    results
  end

  def get_organization_plan_items
    configuration = DocuSign_Admin::Configuration.new
    configuration.host = Rails.configuration.admin_host

    api_client = DocuSign_Admin::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")

    #ds-snippet-start:Admin13Step3
    asset_group_api = DocuSign_Admin::ProvisionAssetGroupApi.new(api_client)
    results, _status, headers = asset_group_api.get_organization_plan_items_with_http_info(args[:organization_id])

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:Admin13Step3

    results
  end
end
