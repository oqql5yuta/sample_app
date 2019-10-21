require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end
  
  test "should redirect index when not logged in" do
    get users_path                                                              # index(/users)を取得
    assert_redirected_to login_url                                              # ログインページへリダイレクトできたらtrue
  end
  
  test "should get signup" do
    get signup_path
    assert_response :success
    # assert_select "title", "Sign up | Ruby on Rails Tutorial Sample App"
  end

  test "should redirect edit when not logged in" do
    get edit_user_path(@user)                                                   # ログインユーザーの編集ページを取得
    assert_not flash.empty?                                                     # flashが空でないならtrue
    assert_redirected_to login_url                                              # ログインユーザーのidのURLへ飛べたらtrue
  end
  
  test "should redirect update when not logged in" do
    patch user_path(@user), params: { user: { name: @user.name,                 # ログインユーザーへ、保存ユーザーの名前とメルアドを引数に取り送信(更新)
                                              email: @user.email } }
    assert_not flash.empty?                                                     # flashが空でないならtrue
    assert_redirected_to login_url                                              # ログインユーザーのidのURLへ飛べたらtrue
  end
 
  test "should not allow the admin attribute to be edited via the web" do
    log_in_as(@other_user)                                                    # @other_userでログインする
    assert_not @other_user.admin?                                             # @other_userが管理権限あれば(adminがtrueなら)falseを返す
    patch user_path(@other_user), params: {                                   # /users/@other_user へparamsハッシュの中身を送る
                                  user: { password:               'password',
                                          password_confirmation:  'password',
                                          admin: true } }
    assert_not @other_user.reload.admin?                                      # @other_userを再読み込みし、admin論理値が変更されてないか検証(falseやnilならtrue)
  end
 
  test "should redirect edit when logged in as wrong user" do                   # @other_userで編集できるか確認
    log_in_as(@other_user)                                                      # @other_userでログインする
    get edit_user_path(@user)                                                   # @userの編集ページを取得
    assert flash.empty?                                                         # flashが空ならtrue
    assert_redirected_to root_url                                               # root_urlへ移動できればtrue
  end
  
  test "should redirect update when logged in as wrong user" do                 # @other_userで更新できるか確認
    log_in_as(@other_user)                                                      # @other_userでログインする
    patch user_path(@user), params: { user: { name:  @user.name,                # @userのユーザーページへ、フォームに入力したname値・email値を送信(更新)
                                              email: @user.email } }
    assert flash.empty?                                                         # flashが空ならtrue
    assert_redirected_to root_url                                               # root_urlへ移動できればtrue
  end

  test "should redirect destroy when not logged in" do                          # ログインしていないユーザーのテスト
    assert_no_difference 'User.count' do                                        # User.count が違わない(同じ)とき、@userのuser_pathを削除する
      delete user_path(@user)
    end
    assert_redirected_to login_url                                              # ログイン画面にリダイレクト
  end

  test "should redirect destroy when logged in as a non-admin" do               # ログイン済みだが管理者権限のないユーザーのテスト
    log_in_as(@other_user)                                                      # 違うユーザーでログインした状態
    assert_no_difference 'User.count' do                                        # User.count が違わない(同じ)とき、@userのuser_pathを削除する
      delete user_path(@user)
    end
    assert_redirected_to root_url                                               # ログイン画面にリダイレクト
  end
end
