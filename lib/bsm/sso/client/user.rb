class Bsm::Sso::Client::User < ActiveResource::Base
  self.format = :json

  class << self

    def headers
      { 'AUTHORIZATION' => Bsm::Sso::Client.verifier.generate(30.seconds.from_now) }
    end

    def consume(ticket, service)
      # TODO rename Sso endpoint to /validate
      find :one, :from => '/validate', :params => { :ticket => ticket, :service => service }
    rescue ActiveResource::ResourceInvalid
      nil
    end

    def authorize(token)
      find :one, :from => '/authorize', :params => { :auth_token => token }
    rescue ActiveResource::ResourceInvalid
      nil
    end

    def authenticate(credentials)
      find :one, :from => "/authenticate", :params => credentials.slice(:email, :password)
    rescue ActiveResource::ResourceInvalid
      nil
    end

    def sign_in_url(params = {})
      custom_absolute_method_root_url(:sign_in, params)
    end

    def sign_out_url(params = {})
      custom_absolute_method_root_url(:sign_out, params)
    end

    private

      def custom_absolute_method_root_url(method_name, params = {})
        "#{site.to_s.chomp('/')}/#{method_name}#{query_string(params)}"
      end

  end
end

