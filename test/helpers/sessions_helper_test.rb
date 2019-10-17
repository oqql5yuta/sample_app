require 'test_helper'

class SessionsHelperTest < ActionView::TestCase

    # 永続的セッションのテスト

    def setup
      @user = users(:michael)                                                   # fixtureにあるmichaelをユーザーとして定義
      remember(@user)                                                           # ユーザーをrememberの引数として受け取って記憶する
    end

    test"current_user returns right user when sessions is nil" do
      assert_equal @user, current_user                                          # current_user（現在のログインユーザー）とmichaelが同じかどうかテスト
      assert is_logged_in?                                                      # テストユーザーがログイン中ならtrueを返す、何らかの理由でログイン失敗したらfalse
    end

    test "current_user returns nil when remember digest is wrong" do
      @user.update_attribute(:remember_digest, User.digest(User.new_token))     # @userの記憶ダイジェストが、ハッシュ化した記憶トークンを暗号化した値と同じなら、記憶ダイジェストを更新する
      assert_nil current_user                                                   # 現在のユーザーがnilならtrue(@userが更新できない場合、現在のユーザーがnilになるかどうか検証)
    end
end