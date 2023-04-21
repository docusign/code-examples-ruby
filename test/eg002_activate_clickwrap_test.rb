require 'date'
require 'rubygems'
require 'test/unit'
require_relative './test_helper'
require_relative '../app/services/api_creator'
require_relative '../app/services/clickwrap/eg002_activate_clickwrap_service'

class Eg002ActivateClickwrapTest < TestHelper
  setup do
    setup_test_data [api_type[:click]]

    args = {
      account_id: @account_id,
      base_path: @base_path,
      access_token: @access_token,

      ds_account_id: @account_id,
      ds_base_path: @base_path,
      ds_access_token: @access_token,

      clickwrap_id: TestData.get_clickwrap_id
    }

    @ceg002 = Clickwrap::Eg002ActivateClickwrapService.new(args)
  end

  test 'should correctly activate clickwrap if correct data is provided' do
    results = @ceg002.worker

    assert_not_nil results
  end

  test 'should get the list of inactive clickwraps if correct data is provided' do
    statuses = %w[inactive draft]
    results = @ceg002.get_inactive_clickwraps statuses

    assert_not_nil results
  end
end
