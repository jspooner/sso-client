require 'spec_helper'

describe Bsm::Sso::Client::UserMethods do

  class TestCustomUserRecord < Hash
    include Bsm::Sso::Client::UserMethods

    def initialize(attrs)
      super()
      update(attrs) if attrs
    end
  end

  subject { TestCustomUserRecord }

  before do
    stub_request(:any, //).to_return(:body => "{}")
  end

  it 'should delegate methods to the user resource' do
    subject.sso_find('1').should be_a(described_class)
    subject.sso_consume('T', 'S').should be_a(described_class)
    subject.sso_authorize('TOK').should be_a(described_class)
    subject.sso_authenticate(:email => "e", :password => "p").should be_a(described_class)
    subject.sso_sign_in_url.should == "https://sso.test.host/sign_in"
    subject.sso_sign_out_url.should == "https://sso.test.host/sign_out"
  end

end
