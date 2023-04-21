require 'date'
require 'rubygems'
require 'test/unit'
require_relative './test_helper'
require_relative '../app/services/api_creator'
require_relative '../app/services/clickwrap/eg001_create_clickwrap_service'

class Eg001CreateClickwrapTest < TestHelper
  setup do
    setup_test_data [api_type[:click]]

    args = {
      account_id: @account_id,
      base_path: @base_path,
      access_token: @access_token,
      doc_pdf: @data[:term_of_service],
      clickwrap_name: "#{@data[:clickwrap_name]}_#{Time.now.strftime("%s%L")}"
    }

    @ceg001 = Clickwrap::Eg001CreateClickwrapService.new(args)
  end

  test 'should correctly create clickwrap if correct data is provided' do
    results = @ceg001.worker

    TestData.set_clickwrap_id(results.clickwrap_id)

    assert_not_nil results
    assert_not_empty results.clickwrap_id
  end
end
