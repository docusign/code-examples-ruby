# frozen_string_literal: true

require 'test_helper'

class Eg010SendBinaryDocsControllerTest < ActionDispatch::IntegrationTest
  test 'should get get' do
    get eg010_send_binary_docs_get_url
    assert_response :success
  end

  test 'should get create' do
    get eg010_send_binary_docs_create_url
    assert_response :success
  end
end
