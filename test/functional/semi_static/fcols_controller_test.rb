require 'test_helper'

module SemiStatic
  class FcolsControllerTest < ActionController::TestCase
    setup do
      @fcol = fcols(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:fcols)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create fcol" do
      assert_difference('Fcol.count') do
        post :create, fcol: {  }
      end
  
      assert_redirected_to fcol_path(assigns(:fcol))
    end
  
    test "should show fcol" do
      get :show, id: @fcol
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @fcol
      assert_response :success
    end
  
    test "should update fcol" do
      put :update, id: @fcol, fcol: {  }
      assert_redirected_to fcol_path(assigns(:fcol))
    end
  
    test "should destroy fcol" do
      assert_difference('Fcol.count', -1) do
        delete :destroy, id: @fcol
      end
  
      assert_redirected_to fcols_path
    end
  end
end
