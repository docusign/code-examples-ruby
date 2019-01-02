require 'test_helper'

class ListEnvelopesControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get list_envelopes_create_url
    assert_response :success
  end

end
