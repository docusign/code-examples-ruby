require 'date'
require 'rubygems'
require 'test/unit'
require_relative './test_helper'
require_relative '../app/services/api_creator'
require_relative '../app/services/e_sign/eg028_brands_creating_service'

class Eg028BrandsCreatingTest < TestHelper
  setup do
    setup_test_data [api_type[:e_sign]]

    args = {
      account_id: @account_id,
      base_path: @base_path,
      access_token: @access_token,
      brandName: "#{@data[:brand_name]}_#{Time.now.strftime("%s%L")}",
      defaultBrandLanguage: @data[:default_brand_language]
    }

    @eg028 = ESign::Eg028BrandsCreatingService.new(args)
  end

  test 'should correctly create brand if correct data is provided' do
    results = @eg028.worker

    TestData.set_brand_id results.brands[0].brand_id

    assert_not_nil results
    assert_not_nil results.brands
    assert_not_nil results.brands[0]
    assert_not_empty results.brands[0].brand_id
  end
end
