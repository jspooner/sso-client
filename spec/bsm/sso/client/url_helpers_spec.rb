require 'spec_helper'

describe Bsm::Sso::Client::UrlHelpers do

  before do
    Warden::Strategies.clear!

    helpers = self.described_class
    Warden::Strategies.add(:foo) do
      include helpers
      def authenticate!; end
    end
  end

  def strategy(*params)
    pairs = ActiveSupport::OrderedHash.new
    params.each_slice(2) {|k,v| pairs[k] = v }
    Warden::Strategies[:foo].new(env_with_params('/', pairs))
  end

  it "should normalized the requested url" do
    strategy.service_url.should == "http://example.org/"
    strategy(:ticket, "ST-1234-ABCD").service_url.should == "http://example.org/"
    strategy( :a, "1", :ticket, "ST-1234-ABCD").service_url.should == "http://example.org/?a=1"
    strategy(:ticket, "ST-1234-ABCD", :z, '3').service_url.should == "http://example.org/?z=3"
    strategy(:a, "1", :ticket, "ST-1234-ABCD", :z, "3").service_url.should == "http://example.org/?a=1&z=3"
  end

end
