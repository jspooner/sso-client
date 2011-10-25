require 'spec_helper'

describe Warden::SessionSerializer do

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
    Bsm::Sso::Client::User.should_receive(:find_for_sso).with(123).and_return(user)
    @session.fetch(:default).should == user
  end

end
