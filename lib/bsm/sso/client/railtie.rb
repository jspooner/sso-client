require 'bsm/sso/client'
require 'rails'

class Bsm::Sso::Client::Railtie < ::Rails::Railtie

  initializer "bsm-sso.insert_middleware" do |app|
    Bsm::Sso::Client::Railtie.insert_middleware!(app)
  end

  config.after_initialize do
    Bsm::Sso::Client::Railtie.handle_exceptions!
  end

  def self.insert_middleware!(app)
    app.config.middleware.use RailsWarden::Manager do |manager|
      manager.default_strategies :sso_ticket, :sso_http_auth
      manager.failure_app = Bsm::Sso::Client::FailureApp
    end
  end

  def self.handle_exceptions!
    return unless defined?(::ActionDispatch::ShowExceptions)
    ActionDispatch::ShowExceptions.rescue_responses.update("Bsm::Sso::Client::UnauthorizedAccess" => :forbidden)
  end

  def self.plugin!(app)
    insert_middleware!(app)
    handle_exceptions!
  end

end
