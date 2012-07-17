require 'test_helper'

class ChatUsersControllerTest < ActionController::TestCase
  setup do
    @chat_user = chat_users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:chat_users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create chat_user" do
    assert_difference('ChatUser.count') do
      post :create, chat_user: { avatar_link: @chat_user.avatar_link, first_name: @chat_user.first_name, last_name: @chat_user.last_name, uid: @chat_user.uid, user_id: @chat_user.user_id, user_node: @chat_user.user_node, username: @chat_user.username }
    end

    assert_redirected_to chat_user_path(assigns(:chat_user))
  end

  test "should show chat_user" do
    get :show, id: @chat_user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @chat_user
    assert_response :success
  end

  test "should update chat_user" do
    put :update, id: @chat_user, chat_user: { avatar_link: @chat_user.avatar_link, first_name: @chat_user.first_name, last_name: @chat_user.last_name, uid: @chat_user.uid, user_id: @chat_user.user_id, user_node: @chat_user.user_node, username: @chat_user.username }
    assert_redirected_to chat_user_path(assigns(:chat_user))
  end

  test "should destroy chat_user" do
    assert_difference('ChatUser.count', -1) do
      delete :destroy, id: @chat_user
    end

    assert_redirected_to chat_users_path
  end
end
