module Bsm::Sso::Client::UserMethods
  extend ActiveSupport::Concern

  included do
    class << self
      delegate :sso_sign_in_url, :sso_sign_out_url, :to => :"Bsm::Sso::Client::User"
    end
  end

  module ClassMethods

    def sso_find(*a)
      result = Bsm::Sso::Client::User.sso_find(*a)
      new(result.attributes) if result
    end

    def sso_consume(*a)
      result = Bsm::Sso::Client::User.sso_consume(*a)
      new(result.attributes) if result
    end

    def sso_authenticate(*a)
      result = Bsm::Sso::Client::User.sso_authenticate(*a)
      new(result.attributes) if result
    end

    def sso_authorize(*a)
      result = Bsm::Sso::Client::User.sso_authorize(*a)
      new(result.attributes) if result
    end

  end
end

