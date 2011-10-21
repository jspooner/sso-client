require 'spec_helper'

describe Bsm::Sso::Client::User do

  it 'should preset format' do
    described_class.format.should == ActiveResource::Formats::JsonFormat
  end

  it 'should use site from configuration' do
    described_class.site.to_s.should == 'https://sso.test.host/'
  end

  it 'should set token in headers using secret' do
    Time.stub! :now => Time.at(0)
    described_class.headers.should == {"AUTHORIZATION"=>"BAhJdToJVGltZQ0ggBGAAADgAQc6C0Bfem9uZUkiCEJTVAY6BkVUOgtvZmZzZXRpAhAO--053a0134a0e1105fb0bc933be01bf7b092473331"}
  end

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

  it 'should construct sign-in URLs' do
    described_class.sign_in_url(:a => '1').should == "https://sso.test.host/sign_in?a=1"
  end

  it 'should construct sign-out URLs' do
    described_class.sign_out_url(:a => '1').should == "https://sso.test.host/sign_out?a=1"
  end

end
