# frozen_string_literal: true

require 'test_helper'

class Eg004EnvelopeInfoControllerTest < ActionDispatch::IntegrationTest
  test 'should get get' do
    get eg004_envelope_info_get_url
    assert_response :success
  end

  test 'should get create' do
    get eg004_envelope_info_create_url
    assert_response :success
  end
end
