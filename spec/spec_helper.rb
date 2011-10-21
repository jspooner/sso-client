$TESTING=true
$:.unshift File.dirname(__FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'bundler/setup'
require 'webmock/rspec'
WebMock.disable_net_connect!

require 'rails'
require 'bsm/sso/client'

Dir[File.join(File.dirname(__FILE__), "support", "**/*.rb")].each do |f|
  require f
end

Bsm::Sso::Client::User.site = "https://sso.test.host"
RSpec.configure do |c|
  c.include(Bsm::Sso::Client::SpecHelpers)

  c.before do
    Bsm::Sso::Client.stub :secret => "SECRET"
  end
end
