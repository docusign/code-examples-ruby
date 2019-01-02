require 'test_helper'

class Eg005EnvelopeRecipientsControllerTest < ActionDispatch::IntegrationTest
  test "should get get" do
    get eg005_envelope_recipients_get_url
    assert_response :success
  end

  test "should get create" do
    get eg005_envelope_recipients_create_url
    assert_response :success
  end

end
