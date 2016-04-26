require 'test_helper'

module SemiStatic
  class SqueezesControllerTest < ActionController::TestCase
    setup do
      @squeeze = squeezes(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:squeezes)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create squeeze" do
      assert_difference('Squeeze.count') do
        post :create, squeeze: {  }
      end
  
      assert_redirected_to squeeze_path(assigns(:squeeze))
    end
  
    test "should show squeeze" do
      get :show, id: @squeeze
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @squeeze
      assert_response :success
    end
  
    test "should update squeeze" do
      put :update, id: @squeeze, squeeze: {  }
      assert_redirected_to squeeze_path(assigns(:squeeze))
    end
  
    test "should destroy squeeze" do
      assert_difference('Squeeze.count', -1) do
        delete :destroy, id: @squeeze
      end
  
      assert_redirected_to squeezes_path
    end
  end
end
