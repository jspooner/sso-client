require 'spec_helper'

describe Warden::SessionSerializer do
  include Warden::Test::Helpers

  let :env do
    env = env_with_params
    env['rack.session'] ||= {}
    env
  end

  let :user do
    mock "User", :id => 123
  end

  describe "serialization" do

    let :session do
      Warden::SessionSerializer.new(env)
    end

    it "should store users by ID" do
      session.store(user, :default)
      env['rack.session'].should == { "warden.user.default.key"=>123 }
    end

    it "should retrieve users from SSO API" do
      session.store(user, :default)
      Bsm::Sso::Client::User.should_receive(:sso_find).with(123).and_return(user)
      session.fetch(:default).should == user
    end

  end

  describe "timeout" do

    let :warden do
      Warden::Proxy.new env, Warden::Manager.new({})
    end

    it "should set an expiration timestamp on authentication" do
      Time.stub! :now => Time.at(1313131313)
      warden.set_user(user, :event => :authentication)
      env['rack.session'].should == { "warden.user.default.key"=>123, "warden.user.default.session"=>{"expire_at"=>1313134913} }
    end
    it "should logout user when session expires on GET requests"
    it "should continue even with expired sessions on non-GET"

  end

end
