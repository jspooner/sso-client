require 'spec_helper'

describe Warden::SessionSerializer do
  include Warden::Test::Helpers

  before(:each) do
    @env = env_with_params
    @env['rack.session'] ||= {}
    @session = Warden::SessionSerializer.new(@env)
  end

  let :user do
    mock "User", :id => 123
  end

  it "should store users by ID" do
    @session.store(user, :default)
    @env['rack.session'].should == { "warden.user.default.key"=>123 }
  end

  it "should retrieve users from SSO API" do
    @session.store(user, :default)
    Bsm::Sso::Client::User.should_receive(:sso_find).with(123).and_return(user)
    @session.fetch(:default).should == user
  end

  it "should logout when expiration time is passed" do
    @session.store(user, :default)
    Bsm::Sso::Client::User.should_receive(:sso_find).with(123).and_return(user)
    # FIX: This line doesn't check any real stuff. Need to find a way to check :logout
    Warden.on_next_request { |proxy| proxy.should_receive(:logout) }
    @session.fetch(:default).should == user
  end

end
