require 'spec_helper'

describe Bsm::Sso::Client::User do

  it 'should perform requests' do
    stub_request(:any, //).to_return(:body => "{}")
    described_class.find(1)
    a_request(:get, "https://sso.test.host/users/1.json").should have_been_made
  end

  it 'should consume tickets' do
    stub_request(:any, //).to_return(:body => "{}")
    described_class.consume('T', 'S')
    a_request(:get, "https://sso.test.host/validate?service=S&ticket=T").should have_been_made
  end

  it 'should authorize with tokens' do
    stub_request(:any, //).to_return(:body => "{}")
    described_class.authorize('TOK')
    a_request(:get, "https://sso.test.host/authorize?auth_token=TOK").should have_been_made
  end

  it 'should authenticate with credentials' do
    stub_request(:any, //).to_return(:body => "{}")
    described_class.authenticate(:a => 1, :b => 2, :email => "email@example.com", :password => "secret")
    a_request(:get, "https://sso.test.host/authenticate?email=email@example.com&password=secret").should have_been_made
  end

  it 'should construct sign-in URLs' do
    described_class.sign_in_url(:a => '1').should == "https://sso.test.host/sign_in?a=1"
  end

  it 'should construct sign-out URLs' do
    described_class.sign_out_url(:a => '1').should == "https://sso.test.host/sign_out?a=1"
  end

end
