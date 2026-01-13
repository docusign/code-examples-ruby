# frozen_string_literal: true

class ESign::Eg043SharedAccessService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def create_agent
    #ds-snippet-start:eSign43Step2
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:base_path]
    api_client = DocuSign_eSign::ApiClient.new configuration
    api_client.default_headers['Authorization'] = "Bearer #{args[:access_token]}"
    #ds-snippet-end:eSign43Step2

    #ds-snippet-start:eSign43Step3
    users_api = DocuSign_eSign::UsersApi.new api_client
    #ds-snippet-end:eSign43Step3

    # Check if active user already exists
    begin
      options = DocuSign_eSign::ListOptions.new
      options.email = args[:email]
      users, _status, headers = users_api.list_with_http_info args[:account_id], options

      remaining = headers['X-RateLimit-Remaining']
      reset = headers['X-RateLimit-Reset']

      if remaining && reset
        reset_date = Time.at(reset.to_i).utc
        puts "API calls remaining: #{remaining}"
        puts "Next Reset: #{reset_date}"
      end

      if users.result_set_size.to_i.positive?
        user = users.users.find { |u| u.user_status == 'Active' }
        return user unless user.nil?
      end
    rescue DocuSign_eSign::ApiError => e
      error = JSON.parse e.response_body
      raise unless error['errorCode'] == 'USER_LACKS_MEMBERSHIP'
    end

    # Create new user
    #ds-snippet-start:eSign43Step3
    new_users, _status, headers = users_api.create_with_http_info args[:account_id], new_users_definition(args)

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end

    new_users.new_users[0]
    #ds-snippet-end:eSign43Step3
  end

  def create_authorization
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:base_path]
    api_client = DocuSign_eSign::ApiClient.new configuration
    api_client.default_headers['Authorization'] = "Bearer #{args[:access_token]}"

    #ds-snippet-start:eSign43Step4
    accounts_api = DocuSign_eSign::AccountsApi.new api_client

    # Check if authorization with manage permission already exists
    options = DocuSign_eSign::GetAgentUserAuthorizationsOptions.new
    options.permissions = 'manage'

    authorizations, _status, headers = accounts_api.get_agent_user_authorizations_with_http_info(args[:account_id], args[:agent_user_id], options)

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end

    return if authorizations.result_set_size.to_i.positive?

    # Create authorization
    _results, _status, headers = accounts_api.create_user_authorization_with_http_info(
      args[:account_id],
      args[:user_id],
      user_authorization_request(args)
    )

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    return unless remaining && reset

    reset_date = Time.at(reset.to_i).utc
    puts "API calls remaining: #{remaining}"
    puts "Next Reset: #{reset_date}"

    #ds-snippet-end:eSign43Step4
  end

  #ds-snippet-start:eSign43Step3
  def new_users_definition(args)
    agent = DocuSign_eSign::UserInformation.new(
      userName: args[:user_name],
      email: args[:email],
      activationAccessCode: args[:activation]
    )
    DocuSign_eSign::NewUsersDefinition.new(newUsers: [agent])
  end
  #ds-snippet-end:eSign43Step3

  #ds-snippet-start:eSign43Step4
  def user_authorization_request(args)
    DocuSign_eSign::UserAuthorizationCreateRequest.new(
      agentUser: DocuSign_eSign::AuthorizationUser.new(
        accountId: args[:account_id],
        userId: args[:agent_user_id]
      ),
      permission: 'manage'
    )
  end
  #ds-snippet-end:eSign43Step4

  def get_envelopes
    #ds-snippet-start:eSign43Step5
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = args[:base_path]
    api_client = DocuSign_eSign::ApiClient.new configuration
    api_client.default_headers['Authorization'] = "Bearer #{args[:access_token]}"
    api_client.set_default_header('X-DocuSign-Act-On-Behalf', args[:user_id])
    envelopes_api = DocuSign_eSign::EnvelopesApi.new api_client

    options = DocuSign_eSign::ListStatusChangesOptions.new
    options.from_date = (Date.today - 10).strftime('%Y/%m/%d')
    results, _status, headers = envelopes_api.list_status_changes_with_http_info args[:account_id], options

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end
    #ds-snippet-end:eSign43Step5

    results
  end
end
