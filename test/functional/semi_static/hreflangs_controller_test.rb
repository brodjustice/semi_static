require 'test_helper'

module SemiStatic
  class HreflangsControllerTest < ActionController::TestCase
    setup do
      @hreflang = hreflangs(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:hreflangs)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create hreflang" do
      assert_difference('Hreflang.count') do
        post :create, hreflang: { href: @hreflang.href, locale: @hreflang.locale, seo_id: @hreflang.seo_id }
      end
  
      assert_redirected_to hreflang_path(assigns(:hreflang))
    end
  
    test "should show hreflang" do
      get :show, id: @hreflang
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @hreflang
      assert_response :success
    end
  
    test "should update hreflang" do
      put :update, id: @hreflang, hreflang: { href: @hreflang.href, locale: @hreflang.locale, seo_id: @hreflang.seo_id }
      assert_redirected_to hreflang_path(assigns(:hreflang))
    end
  
    test "should destroy hreflang" do
      assert_difference('Hreflang.count', -1) do
        delete :destroy, id: @hreflang
      end
  
      assert_redirected_to hreflangs_path
    end
  end
end
