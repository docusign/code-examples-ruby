# frozen_string_literal: true

class ESign::Eg024PermissionCreateService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    #ds-snippet-start:eSign24Step4
    accounts_api = create_account_api(args)
    permission_profile_name = args[:permission_profile_name]
    permission_profile_settings = make_permission_profile_settings
    results, _status, headers = accounts_api.create_permission_profile_with_http_info(args[:account_id], { permissionProfileName: permission_profile_name,
                                                                                                           settings: permission_profile_settings },
                                                                                      DocuSign_eSign::CreatePermissionProfileOptions.default)

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end

    results
    #ds-snippet-end:eSign24Step4
  end

  private

  #ds-snippet-start:eSign24Step3
  def make_permission_profile_settings
    {
      useNewDocuSignExperienceInterface: 0,
      allowBulkSending: 'true',
      allowEnvelopeSending: 'true',
      allowSignerAttachments: 'true',
      allowTaggingInSendAndCorrect: 'true',
      allowWetSigningOverride: 'true',
      allowedAddressBookAccess: 'personalAndShared',
      allowedTemplateAccess: 'share',
      enableRecipientViewingNotifications: 'true',
      enableSequentialSigningInterface: 'true',
      receiveCompletedSelfSignedDocumentsAsEmailLinks: 'false',
      signingUiVersion: 'v2',
      useNewSendingInterface: 'true',
      allowApiAccess: 'true',
      allowApiAccessToAccount: 'true',
      allowApiSendingOnBehalfOfOthers: 'true',
      allowApiSequentialSigning: 'true',
      enableApiRequestLogging: 'true',
      allowDocuSignDesktopClient: 'false',
      allowSendersToSetRecipientEmailLanguage: 'true',
      allowVaulting: 'false',
      allowedToBeEnvelopeTransferRecipient: 'true',
      enableTransactionPointIntegration: 'false',
      powerFormRole: 'admin',
      vaultingMode: 'none'
    }
  end
  #ds-snippet-end:eSign24Step3
end
