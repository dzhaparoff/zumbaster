class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_attached_file :avatar,
                    :styles => { :medium => "500x500#", :thumb => "250x250#" },
                    convert_options: { all: '-quality 75 -strip' }

  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

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
      user.name     = auth.info.name
      user.nickname     = auth.info.nickname if user.nickname.nil?
      user.first_name   = auth.info.first_name if user.first_name.nil?
      user.last_name    = auth.info.last_name if user.last_name.nil?
      user.location     = auth.info.location if user.location.nil?
      user.urls     = auth.info.urls if user.urls.nil?
      user.sex      = auth.extra.raw_info.sex if user.sex.nil?
      user.password = Devise.friendly_token[0, 20]

      user.avatar = URI.parse(auth.info.image)

      user.save
    end
  end
end
