require 'spec_helper'

describe Bsm::Sso::Client::User do

  it 'should find instance' do
    request = stub_request(:get, "https://sso.test.host/users/1").with do |req|
      req.headers.keys.should =~ ["Accept", "Authorization", "Content-Type", "Host"]
    end.to_return :status => 200, :body => %({ "id": 1 })
    instance = described_class.sso_find(1)
    instance.should be_instance_of(described_class)
    instance.should == { "id" => 1 }
    request.should have_been_made
  end

  it 'should not fail on missing instances' do
    request  = stub_request(:get, "https://sso.test.host/users/1").to_return :status => 404
    described_class.sso_find(1).should be_nil
    request.should have_been_made
  end

  it 'should not fail on incomplete instances' do
    request  = stub_request(:get, "https://sso.test.host/users/1").to_return :body => "{}"
    described_class.sso_find(1).should be_nil
    request.should have_been_made
  end

  it 'should cache found instances' do
    options = { :namespace => "bsm:sso:client:test", :expires_in => 3600 }
    Bsm::Sso::Client.cache_store.should_receive(:read_entry).
      with("bsm:sso:client:test:users:1", options)
    Bsm::Sso::Client.cache_store.should_receive(:write).
      with("users:1", instance_of(described_class), options)
    stub_request(:any, //).to_return(:body => '{"id":1}')
    described_class.sso_find(1)
  end

  it 'should consume tickets' do
    req = stub_request(:get, "https://sso.test.host/consume?service=S&ticket=T").to_return :body => "{}"
    described_class.sso_consume('T', 'S')
    req.should have_been_made
  end

  it 'should authorize with tokens' do
    req = stub_request(:get, "https://sso.test.host/authorize?auth_token=TOK").to_return :body => "{}"
    described_class.sso_authorize('TOK')
    req.should have_been_made
  end

  it 'should authenticate with credentials' do
    req = stub_request(:get, "https://sso.test.host/authenticate?email=email@example.com&password=secret").to_return :body => "{}"
    described_class.sso_authenticate(:a => 1, :b => 2, :email => "email@example.com", :password => "secret")
    req.should have_been_made
  end

  it 'should construct sign-in URLs' do
    described_class.sso_sign_in_url(:a => '1').should == "https://sso.test.host/sign_in?a=1"
  end

  it 'should construct sign-out URLs' do
    described_class.sso_sign_out_url(:a => '1').should == "https://sso.test.host/sign_out?a=1"
  end

end
