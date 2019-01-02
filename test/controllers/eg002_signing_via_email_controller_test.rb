require 'test_helper'

class Eg002SigningViaEmailControllerTest < ActionDispatch::IntegrationTest
  test "should get get" do
    get eg002_signing_via_email_get_url
    assert_response :success
  end

  test "should get create" do
    get eg002_signing_via_email_create_url
    assert_response :success
  end

end
