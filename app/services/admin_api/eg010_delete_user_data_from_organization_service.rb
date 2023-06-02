# frozen_string_literal: true

class AdminApi::Eg010DeleteUserDataFromOrganizationService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    # Step 2 start
    configuration = DocuSign_Admin::Configuration.new
    configuration.host = Rails.configuration.admin_host

    api_client = DocuSign_Admin::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    # Step 2 end

    # Step 3 start
    users_api = DocuSign_Admin::UsersApi.new(api_client)

    options = DocuSign_Admin::GetUserDSProfilesByEmailOptions.new
    options.email = args[:email]
    result = users_api.get_user_ds_profiles_by_email(args[:organization_id], options)
    user = result.users[0]
    # Step 3 end

    # Step 4 start
    organizations_api = DocuSign_Admin::OrganizationsApi.new(api_client)
    user_data_redaction_request = DocuSign_Admin::IndividualUserDataRedactionRequest.new(
      user_id: user.id,
      memberships: [
        DocuSign_Admin::MembershipDataRedactionRequest.new(
          account_id: user.memberships[0].account_id
        )
      ]
    )
    organizations_api.redact_individual_user_data(args[:organization_id], user_data_redaction_request)
    # Step 4 end
  end
end
