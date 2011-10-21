class Bsm::Sso::Client::Strategies::Base < ::Warden::Strategies::Base

  def user_class
    Bsm::Sso::Client.user_class
  end

end
