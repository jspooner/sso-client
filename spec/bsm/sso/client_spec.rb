require 'spec_helper'

describe Bsm::Sso::Client do

  it 'should be configurable' do
    described_class.configure do |c|
      c.should respond_to(:site=)
      c.should respond_to(:secret=)
      c.site.to_s.should   == "https://sso.test.host"
      c.secret.should == "SECRET"
    end
  end

  it 'should have a default user class' do
    described_class.user_class.should == described_class::User
  end

  it 'should have a message verifier' do
    described_class.verifier.should be_a(ActiveSupport::MessageVerifier)
    described_class.verifier.generate(Time.at(0)).should == "BAhJdToJVGltZQ0ggBGAAAAAAAc6C0Bfem9uZUkiCEJTVAY6BkVUOgtvZmZzZXRpAhAO--973e36b6537b9068b9b201071d94a6b6d347f13e"
  end

end

