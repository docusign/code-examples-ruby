require 'date'
require 'rubygems'
require 'test/unit'
require_relative './test_helper'
require_relative '../app/services/api_creator'
require_relative '../app/services/e_sign/eg024_permission_create_service'

class Eg024PermissionCreateTest < TestHelper
  setup do
    setup_test_data [api_type[:e_sign]]

    args = {
      account_id: @account_id,
      base_path: @base_path,
      access_token: @access_token,
      permission_profile_name: "#{@data[:permission_profile_name]}_#{Time.now.strftime("%s%L")}"
    }

    @eg024 = ESign::Eg024PermissionCreateService.new(args)
  end

  test 'should correctly create permission profile if correct data is provided' do
    results = @eg024.worker

    assert_not_nil results
  end

  test 'should create correct permission profile settings if correct data is provided' do
    expected_permission_profile_settings = {
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

    permission_profile_settings = @eg024.send(:make_permission_profile_settings)

    assert_not_nil permission_profile_settings
    assert_equal expected_permission_profile_settings, permission_profile_settings
  end
end
