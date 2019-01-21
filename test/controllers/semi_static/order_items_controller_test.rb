require 'test_helper'

module SemiStatic
  class OrderItemsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "should get create" do
      get order_items_create_url
      assert_response :success
    end

    test "should get update" do
      get order_items_update_url
      assert_response :success
    end

    test "should get destroy" do
      get order_items_destroy_url
      assert_response :success
    end

  end
end
