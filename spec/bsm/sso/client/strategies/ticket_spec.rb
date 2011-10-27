require 'spec_helper'

describe Bsm::Sso::Client::Strategies::Ticket do

  def strategy(params = {})
    described_class.new(env_with_params('/', params))
  end

  it { strategy.should be_a(described_class) }

  it "should be valid when ticket is given" do
    strategy.should_not be_valid
    strategy(:ticket => "").should_not be_valid
    strategy(:ticket => "ST-1234-ABCD").should be_valid
  end

  it "should authenticate user via consume" do
    Bsm::Sso::Client.user_class.should_receive(:sso_consume).with('T', 'http://example.org/').and_return(Bsm::Sso::Client.user_class.new(:id => 123))
    strategy(:ticket => "T").authenticate!.should == :success
  end

  it "should fail authentication authenticate if user is not consumable" do
    Bsm::Sso::Client.user_class.should_receive(:sso_consume).with('T', 'http://example.org/').and_return(nil)
    strategy(:ticket => "T").authenticate!.should == :failure
  end

end
