require 'bsm/sso/client'
require 'rails'

class Bsm::Sso::Client::Railtie < ::Rails::Railtie

  config.app_middleware.use RailsWarden::Manager do |manager|
    manager.default_strategies :sso_ticket, :sso_http_auth
    manager.failure_app = Bsm::Sso::Client::FailureApp
    Bsm::Sso::Client.warden_configuration.call(manager) if Bsm::Sso::Client.warden_configuration
  end

  config.after_initialize do
    if defined?(::ActionDispatch::ShowExceptions)
      ActionDispatch::ShowExceptions.rescue_responses.update("Bsm::Sso::Client::UnauthorizedAccess" => :forbidden)
    end
  end

end
