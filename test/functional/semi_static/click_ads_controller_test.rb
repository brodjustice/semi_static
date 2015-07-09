require 'test_helper'

module SemiStatic
  class ClickAdsControllerTest < ActionController::TestCase
    setup do
      @click_ad = click_ads(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:click_ads)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create click_ad" do
      assert_difference('ClickAd.count') do
        post :create, click_ad: {  }
      end
  
      assert_redirected_to click_ad_path(assigns(:click_ad))
    end
  
    test "should show click_ad" do
      get :show, id: @click_ad
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @click_ad
      assert_response :success
    end
  
    test "should update click_ad" do
      put :update, id: @click_ad, click_ad: {  }
      assert_redirected_to click_ad_path(assigns(:click_ad))
    end
  
    test "should destroy click_ad" do
      assert_difference('ClickAd.count', -1) do
        delete :destroy, id: @click_ad
      end
  
      assert_redirected_to click_ads_path
    end
  end
end
