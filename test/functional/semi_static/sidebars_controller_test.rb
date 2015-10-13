require 'test_helper'

module SemiStatic
  class SidebarsControllerTest < ActionController::TestCase
    setup do
      @sidebar = sidebars(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:sidebars)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create sidebar" do
      assert_difference('Sidebar.count') do
        post :create, sidebar: {  }
      end
  
      assert_redirected_to sidebar_path(assigns(:sidebar))
    end
  
    test "should show sidebar" do
      get :show, id: @sidebar
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @sidebar
      assert_response :success
    end
  
    test "should update sidebar" do
      put :update, id: @sidebar, sidebar: {  }
      assert_redirected_to sidebar_path(assigns(:sidebar))
    end
  
    test "should destroy sidebar" do
      assert_difference('Sidebar.count', -1) do
        delete :destroy, id: @sidebar
      end
  
      assert_redirected_to sidebars_path
    end
  end
end
