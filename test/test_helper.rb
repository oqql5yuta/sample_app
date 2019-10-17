ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  fixtures :all
  include ApplicationHelper
  # 単体テスト用

  # テストユーザーがログイン中の場合にtrueを返す
  def is_logged_in?
    !session[:user_id].nil?                                                     # セッションが空ならfalse、空じゃない（ログインしていれば)true
  end

  # テストユーザーとしてログインする
  def log_in_as(user)
    session[:user_id] = user.id
  end
end

class ActionDispatch::IntegrationTest
  # 統合テスト用

  # テストユーザーとしてログインする
  def log_in_as(user, password: 'password', remember_me: '1')                   # ログイン時のユーザーとして、チェックボックスにチェックを入れてる(1)
    post login_path, params: { session: { email: user.email,                    # /login に対してparamsとしてsessionハッシュに各属性の値が入れて送信
                                          password: password,
                                          remember_me: remember_me } }
  end
end