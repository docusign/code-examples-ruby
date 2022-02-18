# frozen_string_literal: true

class ESign::Eg026PermissionsChangeSingleSettingService
  attr_reader :args
  include ApiCreator

  def initialize(args)
    @args = args
  end

  def worker
    accounts_api = create_account_api(args)
    permission_profile_settings = make_permission_profile_settings
    permission_profile_id = args[:permission_profile_id]
    update_permission_profile  = accounts_api.update_permission_profile(args[:account_id], permission_profile_id,
                                           permission_profile_settings, options = DocuSign_eSign::UpdatePermissionProfileOptions.default)
  end

  private

  def make_permission_profile_settings
    permission_profile = DocuSign_eSign::PermissionProfile.new
    pr_settings = ({
      useNewDocuSignExperienceInterface: 0,
      allowBulkSending: "true",
      allowEnvelopeSending: "true",
      allowSignerAttachments: "true",
      allowTaggingInSendAndCorrect:"true",
      allowWetSigningOverride:"true",
      allowedAddressBookAccess:"personalAndShared",
      allowedTemplateAccess: "share",
      enableRecipientViewingNotifications:"true",
      enableSequentialSigningInterface:"true",
      receiveCompletedSelfSignedDocumentsAsEmailLinks:"false",
      signingUiVersion:"v2",
      useNewSendingInterface:"true",
      allowApiAccess:"true",
      allowApiAccessToAccount:"true",
      allowApiSendingOnBehalfOfOthers:"true",
      allowApiSequentialSigning:"true",
      enableApiRequestLogging:"true",
      allowDocuSignDesktopClient:"false",
      allowSendersToSetRecipientEmailLanguage:"true",
      allowVaulting:"false",
      allowedToBeEnvelopeTransferRecipient: "true",
      enableTransactionPointIntegration: "false",
      powerFormRole: "admin",
      vaultingMode: "none"
    })
    permission_profile.settings = pr_settings
  end
end