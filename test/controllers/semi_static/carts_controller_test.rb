require 'test_helper'

module SemiStatic
  class CartsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "should get show" do
      get carts_show_url
      assert_response :success
    end

  end
end
