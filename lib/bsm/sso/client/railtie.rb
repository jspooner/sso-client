require 'bsm/sso/client'
require 'rails'

class Bsm::Sso::Client::Railtie < ::Rails::Railtie
  RESCUE_RESPONSES = { "Bsm::Sso::Client::UnauthorizedAccess" => :forbidden }.freeze
  initializer 'bsm-sso.warden' do |app|
    unless defined?(::Devise)
      config.app_middleware.use RailsWarden::Manager do |manager|
        manager.default_strategies :sso_ticket, :sso_http_auth
        manager.failure_app = Bsm::Sso::Client::FailureApp
        Bsm::Sso::Client.warden_configuration.call(manager) if Bsm::Sso::Client.warden_configuration
      end
    end
    if config.action_dispatch.key?(:rescue_responses)
      config.action_dispatch.rescue_responses.merge!(RESCUE_RESPONSES)
    end
  end
end
