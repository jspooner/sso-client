require 'excon'
require 'active_support/json'
require 'active_support/core_ext/object/to_query'
require 'active_support/core_ext/hash/keys'

class Bsm::Sso::Client::AbstractResource < Hash

  class << self

    # @param [String] url
    def site=(url)
      @site = Excon.new url,
        :idempotent => true,
        :expects    => [200, 422],
        :headers    => { 'Accept' => Mime::JSON.to_s, 'Content-Type' => Mime::JSON.to_s }
    end

    # @return [Excon::Connection] site connection
    def site
      @site || (superclass.respond_to?(:site) && superclass.site) || raise("No site specified for #{name}. Please specify #{name}.site = 'http://your.sso.host'")
    end

    # @return [Hash] default headers
    def headers
      { 'Authorization' => Bsm::Sso::Client.verifier.generate(30.seconds.from_now) }
    end

    # @param [String] path
    # @param [Hash] params, request params - see Excon::Connection#request
    # @return [Bsm::Sso::Client::AbstractResource] fetches object from remote
    def get(path, params = {})
      params = params.merge(:path => path)
      params[:headers] = (params[:headers] || {}).merge(headers)
      response = site.get(params)
      return nil unless response.status == 200

      instance = new ActiveSupport::JSON.decode(response.body)
      instance if instance.id
    rescue MultiJson::DecodeError
      nil
    end

  end

  # Constuctor
  # @param [Hash,NilClass] attributes the attributes to assign
  def initialize(attributes = nil)
    super()
    update(attributes.stringify_keys) if attributes.is_a?(Hash)
  end

  # @return [Integer] ID, the primary key
  def id
    self["id"]
  end

  # @return [Boolean] true, if method exists?
  def respond_to?(method, *)
    super || key?(method.to_s)
  end

  # @return [Hash] attributes hash
  def attributes
    dup
  end

  protected

    def method_missing(method, *)
      key?(method.to_s) ? fetch(method.to_s) : super
    end

end