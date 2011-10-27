class Bsm::Sso::Client::User < Bsm::Sso::Client::AbstractResource
  attr_accessor :expires_at

  class << self

    def sso_find(id)
      find id
    end

    def sso_consume(ticket, service)
      find_and_set_expiration :one, :from => '/consume', :params => { :ticket => ticket, :service => service }
    rescue ActiveResource::ResourceInvalid
      nil
    end

    def sso_authorize(token)
      find :one, :from => '/authorize', :params => { :auth_token => token }
    rescue ActiveResource::ResourceInvalid
      nil
    end

    def sso_authenticate(credentials)
      find :one, :from => "/authenticate", :params => credentials.slice(:email, :password)
    rescue ActiveResource::ResourceInvalid
      nil
    end

    def sso_sign_in_url(params = {})
      sso_custom_absolute_method_root_url(:sign_in, params)
    end

    def sso_sign_out_url(params = {})
      sso_custom_absolute_method_root_url(:sign_out, params)
    end

    private

      def sso_custom_absolute_method_root_url(method_name, params = {})
        "#{site.to_s.chomp('/')}/#{method_name}#{query_string(params)}"
      end

      def find_and_set_expiration(*args)
        user = find(*args)
        user.expires_at = Time.now + Bsm::Sso::Client.expire_after
        user
      end

  end
end

