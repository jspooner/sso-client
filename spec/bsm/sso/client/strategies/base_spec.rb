require 'spec_helper'

describe Bsm::Sso::Client::Strategies::Base do

  subject do
    described_class.new(env_with_params)
  end

  it { should be_a(described_class) }

  it "should reference user class" do
    subject.user_class.should == Bsm::Sso::Client::User
  end

end
