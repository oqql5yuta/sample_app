class User < ApplicationRecord
  before_save { email.downcase! }
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i        # addressの制約
  validates :email, presence: true, 
                    length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true  #passwordの文字列が空でなく、6文字以上ならtrue。例外処理に空(nil)の場合のみバリデーションを通す(true)

  # インスタンス変数の定義
  attr_accessor :remember_token
  
  # Userクラスに対して定義する
  class << self
    #password_digestの文字列をハッシュ化して、ハッシュ値として返す
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end
    # ランダムなトークンを返す
    def new_token                                                               # Userクラスにnew_tokenを渡したクラスメソッドを作成
      SecureRandom.urlsafe_base64                                               # SecureRandomモジュールにbase64でランダムな文字列を生成
    end
  end
  
  # 記憶トークンをUserオブジェクトのremember_token属性に代入し、DBに記憶ダイジェストとして保存
  def remember
    self.remember_token = User.new_token                                        # 記憶トークンをremember_token属性に代入 
    update_attribute(:remember_digest, User.digest(remember_token))             # DBのremember_token属性値をBcryptに渡してハッシュ化して更新
  end
  
  # 引数として受け取った値を記憶トークンに代入して暗号化（記憶ダイジェスト）し、DBにいるユーザーの記憶ダイジェストと比較、同一ならtrueを返す
  def authenticated?(remember_token)
    return false if remember_digest.nil?                                        # 記憶ダイジェストがnilの場合、falseを戻り値として返す
    BCrypt::Password.new(remember_digest).is_password?(remember_token)          # DBの記憶ダイジェストと、受け取った記憶トークンを記憶ダイジェストにした値を比較
  end  
  
 # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)                                     # DBにある記憶ダイジェストをnilにする
  end
end