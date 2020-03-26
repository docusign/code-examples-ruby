# frozen_string_literal: true

require 'test_helper'

class DsControllerTest < ActionDispatch::IntegrationTest
  test 'should get ds_return' do
    get ds_ds_return_url
    assert_response :success
  end
end
