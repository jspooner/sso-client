require 'spec_helper'

describe Bsm::Sso::Client::Strategies::HttpAuth do

  def strategy(authorization = nil)
    env = {}
    env['HTTP_AUTHORIZATION'] = authorization if authorization
    described_class.new(env_with_params('/', {}, env))
  end

  it { strategy.should be_a(described_class) }

  it "should be valid when authorization token is given" do
    strategy.should_not be_valid
    strategy("").should_not be_valid
    strategy("WRONG!").should_not be_valid
    strategy("Basic dXNlcjp4\n").should be_valid
  end

  it "should not remember user" do
    strategy.should_not be_store
  end

  it "should extract token" do
    strategy.token.should be_nil
    strategy("").token.should be_nil
    strategy("WRONG!").token.should be_nil
    strategy("Basic dXNlcjp4\n").token.should == "user"
  end

  it "should authenticate user via authorize" do
    Bsm::Sso::Client.user_class.should_receive(:sso_authorize).with('user').and_return(Bsm::Sso::Client.user_class.new(:id => 123))
    strategy("Basic dXNlcjp4\n").authenticate!.should == :success
  end

  it "should fail authentication authenticate if user is not authorizable" do
    Bsm::Sso::Client.user_class.should_receive(:sso_authorize).with('user').and_return(nil)
    strategy("Basic dXNlcjp4\n").authenticate!.should == :failure
  end

end
