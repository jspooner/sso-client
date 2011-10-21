module Bsm::Sso::Client::UserMethods
  extend ActiveSupport::Concern

  included do
    class << self
      delegate :sign_in_url, :sign_out_url, :to => :"Bsm::Sso::Client::User"
    end
  end

  module ClassMethods

    def consume(*a)
      result = Bsm::Sso::Client::User.consume(*a)
      new(result.attributes) if result
    end

    def authenticate(*a)
      result = Bsm::Sso::Client::User.authenticate(*a)
      new(result.attributes) if result
    end

    def authorize(*a)
      result = Bsm::Sso::Client::User.authorize(*a)
      new(result.attributes) if result
    end

  end
end

