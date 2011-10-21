class Bsm::Sso::Client::AbstractResource < ActiveResource::Base
  self.format = :json

  class << self

    def headers
      { 'AUTHORIZATION' => Bsm::Sso::Client.verifier.generate(30.seconds.from_now) }
    end

  end
end

