require 'spec_helper'

describe Bsm::Sso::Client::Strategies::APIToken do

  def strategy(authorization = nil, format = Mime::JSON, env = {})
    env['HTTP_AUTHORIZATION'] = authorization if authorization
    env["action_dispatch.request.formats"] = [format]
    described_class.new(env_with_params('/', {}, env))
  end

  let :time do
    10.minutes.from_now
  end

  def basic_auth(object = time)
    user = described_class.verifier.generate(object)
    "Basic " + ["#{user}:x"].pack('m')
  end

  it { strategy.should be_a(described_class) }
  it { strategy.should be_a(Bsm::Sso::Client::Strategies::HttpAuth) }

  it "should default to global secret token" do
    described_class.secret.should == "SECRET"
  end

  it "should default to global secret token" do
    begin
      described_class.secret = "CUSTOM"
      described_class.secret.should == "CUSTOM"
    ensure
      described_class.instance_variable_set :@secret, nil
      described_class.secret.should == "SECRET"
    end
  end

  it "should be valid when API request" do
    strategy(basic_auth).should be_valid
    strategy(basic_auth, Mime::XML, :method => "GET").should be_valid
    strategy(basic_auth, Mime::XML, :method => "POST").should be_valid
    strategy(basic_auth, Mime::HTML).should_not be_valid
    strategy(basic_auth, Mime::ALL).should_not be_valid
    strategy(basic_auth, nil).should_not be_valid
  end

  it "should be valid when authorization is valid" do
    strategy.should_not be_valid
    strategy("").should_not be_valid
    strategy("WRONG!").should_not be_valid
    strategy(basic_auth(Date.today)).should_not be_valid
    strategy(basic_auth).should be_valid
  end

  it "should generate expiration" do
    strategy.expiration.should be_nil
    strategy("").expiration.should be_nil
    strategy("WRONG!").expiration.should be_nil
    strategy(basic_auth(Date.today)).expiration.should be_nil
    strategy(basic_auth).expiration.should == time
    strategy(basic_auth(Time.now)).expiration.should be_a(Time)
  end

  it "should authenticate user if request not expired" do
    strategy(basic_auth).authenticate!.should == :success
  end

  it "should fail authentication if request expired" do
    strategy(basic_auth(Time.now - 1)).authenticate!.should == :failure
  end

end
