class Bsm::Sso::Client::Strategies::APIToken < Bsm::Sso::Client::Strategies::HttpAuth

  def self.verifier
    @verifier ||= ActiveSupport::MessageVerifier.new(secret)
  end

  def self.secret=(value)
    @verifier = nil
    @secret   = value
  end

  def self.secret
    @secret ||= Bsm::Sso::Client.secret
  end

  def self.user_instance
    Bsm::Sso::Client.user_instance
  end

  def api_format?
    Bsm::Sso::Client.api_formats.include? request.format.try(:to_sym)
  end

  def valid?
    api_format? && super && !!expiration
  end

  def authenticate!
    if expiration >= Time.now
      success!(user_instance)
    else
      fail!(:expired)
    end
  end

  def expiration
    return @expiration if defined?(@expiration)

    @expiration = begin
      result = self.class.verifier.verify(token)
      result if result.acts_like?(:time)
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      nil
    end
  end

  Warden::Strategies.add :sso_api_token, self
end

