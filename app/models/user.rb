class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook, :google_oauth2]

  ratyrate_rater

  validates :first_name, presence: true, length: { maximum: 255 }
  validates :last_name, presence: true, length: { maximum: 255 }

  def self.per_page
    10
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def self.find_for_facebook_oauth(auth, signed_in_resource = nil)
    Rails.logger.debug YAML::dump(auth)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    if user
      return user
    else
      registered_user = User.where(:email => auth.info.email).first
      if registered_user
        return registered_user
      else
        user = User.create(
            provider:auth.provider,
            uid:auth.uid,
            email:auth.info.email,
            first_name: auth.info.first_name,
            last_name: auth.info.last_name,
            password:Devise.friendly_token[0,20]
        )
        #PartnerMailer.welcome(user).deliver
        return user
      end

    end
  end

  def self.find_for_google_oauth2(access_token, signed_in_resource = nil)
    data = access_token.info
    user = User.where(:provider => access_token.provider, :uid => access_token.uid ).first
    if user
      return user
    else
      registered_user = User.where(:email => access_token.info.email).first
      if registered_user
        return registered_user
      else
        user = User.create(
            provider:access_token.provider,
            first_name: data["first_name"],
            last_name: data["last_name"],
            email: data["email"],
            uid: access_token.uid ,
            password: Devise.friendly_token[0,20]
        )
        # PartnerMailer.welcome(user).deliver
        return user
      end
    end
  end

  def active_for_authentication?
    super and self.is_active?
  end

end
