require 'test_helper'

class EmbeddedSigningControllerTest < ActionDispatch::IntegrationTest
  test "should get get" do
    get embedded_signing_get_url
    assert_response :success
  end

  test "should get create" do
    get embedded_signing_create_url
    assert_response :success
  end

end
