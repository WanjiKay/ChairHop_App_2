require "test_helper"

class StylistsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get stylists_show_url
    assert_response :success
  end
end
