require 'spec_helper'

describe Bsm::Sso::Client::User do

  it 'should find instance' do
    stub_request(:any, //).to_return(:body => "{}")
    described_class.sso_find(1)
    a_request(:get, "https://sso.test.host/users/1.json").should have_been_made
  end

  it 'should cache found instances' do
    options = { :namespace => "bsm:sso:client:test", :expires_in => 3600 }
    Bsm::Sso::Client.cache_store.should_receive(:read_entry).
      with("bsm:sso:client:test:users:1", options)
    Bsm::Sso::Client.cache_store.should_receive(:write).
      with("users:1", instance_of(described_class), options)
    stub_request(:any, //).to_return(:body => "{}")
    described_class.sso_find(1)
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

end
