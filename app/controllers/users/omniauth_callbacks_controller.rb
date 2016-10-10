class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook

    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end

  end

  def vkontakte

    @user = User.from_omniauth_vk(request.env["omniauth.auth"])

    # {
    #     "provider" => "vkontakte",
    #     "uid" => "13497867",
    #     "info" => {
    #         "name" => "Энвер Джапаров",
    #         "nickname" => "",
    #         "email" => "d_enver@mail.ru",
    #         "first_name" => "Энвер",
    #         "last_name" => "Джапаров",
    #         "image" => "http://cs614925.vk.me/v614925867/8153/wNIld0CUBcA.jpg",
    #         "location" => "Россия, Москва",
    #         "urls" => {
    #             "Vkontakte" => "http://vk.com/d_enver"
    #         }
    #     },
    #     "credentials" => {
    #         "token" => "9a691fc3bd99e17678244d38a4b6a33d937d489cbcd2b2e56bf01e748db73b9fca994d5cc6687658991a9",
    #         "expires_at" => 1431904502,
    #         "expires" => true
    #     },
    #     "extra" => {
    #         "raw_info" => {
    #             "id" => 13497867,
    #             "first_name" => "Энвер",
    #             "last_name" => "Джапаров",
    #             "sex" => 2,
    #             "nickname" => "",
    #             "screen_name" => "d_enver",
    #             "bdate" => "22.9.1988",
    #             "city" => 1,
    #             "country" => 1,
    #             "photo_50" => "http://cs614925.vk.me/v614925867/8157/YbldHLoe-WE.jpg",
    #             "photo_100" => "http://cs614925.vk.me/v614925867/8156/-7f86rXgr2w.jpg",
    #             "photo_200_orig" => "http://cs614925.vk.me/v614925867/8153/wNIld0CUBcA.jpg",
    #             "online" => 0
    #         }
    #     }
    # }

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Vkontakte") if is_navigational_format?
    else
      session["devise.vkontakte_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
end