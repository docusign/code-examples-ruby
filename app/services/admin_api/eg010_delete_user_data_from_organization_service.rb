# frozen_string_literal: true

class AdminApi::Eg010DeleteUserDataFromOrganizationService
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:Admin10Step2
    configuration = DocuSign_Admin::Configuration.new
    configuration.host = Rails.configuration.admin_host

    api_client = DocuSign_Admin::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
    #ds-snippet-end:Admin10Step2

    # Get user
    users_api = DocuSign_Admin::UsersApi.new(api_client)

    options = DocuSign_Admin::GetUserDSProfilesByEmailOptions.new
    options.email = args[:email]
    result = users_api.get_user_ds_profiles_by_email(args[:organization_id], options)
    user = result.users[0]

    #ds-snippet-start:Admin10Step3
    organizations_api = DocuSign_Admin::OrganizationsApi.new(api_client)
    user_data_redaction_request = DocuSign_Admin::IndividualUserDataRedactionRequest.new(
      user_id: user.id,
      memberships: [
        DocuSign_Admin::MembershipDataRedactionRequest.new(
          account_id: user.memberships[0].account_id
        )
      ]
    )
    #ds-snippet-end:Admin10Step3

    #ds-snippet-start:Admin10Step4
    organizations_api.redact_individual_user_data(args[:organization_id], user_data_redaction_request)
    #ds-snippet-end:Admin10Step4
  end
end
