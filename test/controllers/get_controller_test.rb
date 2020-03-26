# frozen_string_literal: true

require 'test_helper'

class GetControllerTest < ActionDispatch::IntegrationTest
  test 'should get create' do
    get get_create_url
    assert_response :success
  end
end
