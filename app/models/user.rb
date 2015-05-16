class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_attached_file :avatar, :styles => { :medium => "500x500#", :thumb => "250x250#" }, convert_options: { all: '-quality 75 -strip' }

  devise :database_authenticatable,
         :rememberable, :trackable, :validatable, :registerable,
         :omniauthable, omniauth_providers: [:vkontakte, :facebook]

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email    = auth.info.email
      user.password = Devise.friendly_token[0, 20]
    end
  end

  def self.from_omniauth_vk(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email    = auth.info.email
      user.password = Devise.friendly_token[0, 20]
    end
  end
end
