require 'spec_helper'

describe Bsm::Sso::Client do

  it 'should be configurable' do
    described_class.configure do |c|
      c.should respond_to(:site=)
      c.should respond_to(:secret=)
      c.site.should be_instance_of(Excon::Connection)
      c.secret.should == "SECRET"
    end
  end

  it 'should allow to configure warden' do
    described_class.warden_configuration.should be_nil
    block = lambda {|m| }
    described_class.warden &block
    described_class.warden_configuration.should == block
  end

  it 'should have a default user class' do
    described_class.user_class.should == described_class::User
  end

  it 'should have a message verifier' do
    described_class.verifier.should be_a(ActiveSupport::MessageVerifier)
    described_class.verifier.generate(Time.at(0).utc).should == "BAhJdToJVGltZQ0ggBHAAAAAAAY6C0Bfem9uZUkiCFVUQwY6BkVU--e12c751a942753c2a016e736d28ab53f856950ca"
  end

  it 'should have a default user class' do
    request = mock("Request", :path => "/admin")
    lambda { described_class.forbidden!(request) }.should raise_error(Bsm::Sso::Client::UnauthorizedAccess)
  end

  it 'should have a cache store' do
    described_class.cache_store.should be_instance_of(ActiveSupport::Cache::NullStore)
    described_class.cache_store.options.should == { :namespace => "bsm:sso:client:test" }
  end

end

