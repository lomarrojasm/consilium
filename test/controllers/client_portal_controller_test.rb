require "test_helper"

class ClientPortalControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get client_portal_index_url
    assert_response :success
  end
end
