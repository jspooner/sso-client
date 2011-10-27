require 'spec_helper'

describe Bsm::Sso::Client::User do

  it 'should find instance' do
    stub_request(:any, //).to_return(:body => "{}")
    described_class.sso_find(1)
    a_request(:get, "https://sso.test.host/users/1.json").should have_been_made
  end

  it 'should consume tickets' do
    stub_request(:any, //).to_return(:body => "{}")
    described_class.sso_consume('T', 'S')
    a_request(:get, "https://sso.test.host/consume?service=S&ticket=T").should have_been_made
  end

  it 'should authorize with tokens' do
    stub_request(:any, //).to_return(:body => "{}")
    described_class.sso_authorize('TOK')
    a_request(:get, "https://sso.test.host/authorize?auth_token=TOK").should have_been_made
  end

  it 'should authenticate with credentials' do
    stub_request(:any, //).to_return(:body => "{}")
    described_class.sso_authenticate(:a => 1, :b => 2, :email => "email@example.com", :password => "secret")
    a_request(:get, "https://sso.test.host/authenticate?email=email@example.com&password=secret").should have_been_made
  end

  it 'should construct sign-in URLs' do
    described_class.sso_sign_in_url(:a => '1').should == "https://sso.test.host/sign_in?a=1"
  end

  it 'should construct sign-out URLs' do
    described_class.sso_sign_out_url(:a => '1').should == "https://sso.test.host/sign_out?a=1"
  end

  it 'should set expiration time on consuming' do
    Time.should_receive(:now).and_return(Time.at(10))
    user = mock "User"
    user.should_receive(:expires_at=).with(Time.at(10) + 1.hour)
    described_class.should_receive(:find).and_return(user)
    described_class.sso_consume('T', 'S')
  end

end
