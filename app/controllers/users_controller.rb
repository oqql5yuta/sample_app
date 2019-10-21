class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]       # index, edit, update, destroyアクションにlogged_in_userメソッドを適用
  before_action :correct_user,   only: [:edit, :update]                         # editとupdateアクションにcorrect_userメソッドを適用
  before_action :admin_user,     only: :destroy
  
  def index
    @users = User.paginate(page: params[:page])                                  # Userを取り出して分割した値を@usersに代入
  end
  
  def show
    @user = User.find(params[:id])
    
  end
  
  def new
    @user = User.new
    # debugger
  end
  
  def create
    @user = User.new(user_params)                                               # newビューにて送ったformの中身(nameやemailの値)をuser_paramsで受け取り、ユーザーオブジェクトを生成、@userに代入   
    if @user.save
      log_in @user                                                              # log_inメソッド(ログイン)の引数として@user(ユーザーオブジェクト)を渡す。要はセッションに渡すってこと
      flash[:success] = "Welcome to the Sample App!"                            # flashの:successシンボルに成功時のメッセージを代入
      redirect_to @user                                                         # (user_url(@user) つまり/users/idへ飛ばす(https://qiita.com/Kawanji01/items/96fff507ed2f75403ecb)を参考
    else
      render 'new'
    end
  end
  
  def edit
    @user = User.find(params[:id])                                              # URLのユーザーidと同じユーザーをDBから取り出して@userに代入
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end
  
  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                  :password_confirmation)
    end
    
    # beforeアクション
    def logged_in_user                                                          # ログイン済みユーザーかどうか確認
      unless logged_in?                                                         # ユーザーがログインしていなければ(false)処理を行う
        store_location                                                          # アクセスしようとしたURLを覚えておく
        flash[:danger] = "Please log in."                                       # エラーメッセージを書く
        redirect_to login_url                                                   # ログインユーザーのidを引数に取ったURLのページへ飛ぶ
      end
    end
    
    def correct_user                                                            # 正しいユーザーかどうか確認
      @user = User.find(params[:id])                                            # URLのidの値と同じユーザーを@userに代入
      redirect_to(root_url) unless current_user?(@user)                         # @userと記憶トークンcookieに対応するユーザー(current_user)を比較して、失敗したらroot_urlへリダイレクト
    end
    
    def admin_user                                                              # 管理者のみに適用
      redirect_to(root_url) unless current_user.admin?                          # 現在のユーザーが管理者でなければroot_urlへリダイレクト
    end
end
