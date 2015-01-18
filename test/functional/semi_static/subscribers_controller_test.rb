require 'test_helper'

module SemiStatic
  class SubscribersControllerTest < ActionController::TestCase
    setup do
      @subscriber = subscribers(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:subscribers)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create subscriber" do
      assert_difference('Subscriber.count') do
        post :create, subscriber: { cancel_token: @subscriber.cancel_token, email: @subscriber.email, name: @subscriber.name, surname: @subscriber.surname, telephone: @subscriber.telephone }
      end
  
      assert_redirected_to subscriber_path(assigns(:subscriber))
    end
  
    test "should show subscriber" do
      get :show, id: @subscriber
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @subscriber
      assert_response :success
    end
  
    test "should update subscriber" do
      put :update, id: @subscriber, subscriber: { cancel_token: @subscriber.cancel_token, email: @subscriber.email, name: @subscriber.name, surname: @subscriber.surname, telephone: @subscriber.telephone }
      assert_redirected_to subscriber_path(assigns(:subscriber))
    end
  
    test "should destroy subscriber" do
      assert_difference('Subscriber.count', -1) do
        delete :destroy, id: @subscriber
      end
  
      assert_redirected_to subscribers_path
    end
  end
end
