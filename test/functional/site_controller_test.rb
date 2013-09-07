require 'test_helper'

class SiteControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
  end

  test "should get info" do
    get :info
    assert_response :success
  end

  test "should get signin" do
    get :signin
    assert_response :success
  end

end
