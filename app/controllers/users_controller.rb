class UsersController < ApplicationController
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

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                  :password_confirmation)
    end
end
