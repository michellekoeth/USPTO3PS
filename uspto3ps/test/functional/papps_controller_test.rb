require 'test_helper'

class PappsControllerTest < ActionController::TestCase
  setup do
    @papp = papps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:papps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create papp" do
    assert_difference('Papp.count') do
      post :create, papp: @papp.attributes
    end

    assert_redirected_to papp_path(assigns(:papp))
  end

  test "should show papp" do
    get :show, id: @papp
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @papp
    assert_response :success
  end

  test "should update papp" do
    put :update, id: @papp, papp: @papp.attributes
    assert_redirected_to papp_path(assigns(:papp))
  end

  test "should destroy papp" do
    assert_difference('Papp.count', -1) do
      delete :destroy, id: @papp
    end

    assert_redirected_to papps_path
  end
end
