require 'spec_helper'

describe Bsm::Sso::Client::AbstractResource do

  it 'should use site from configuration' do
    described_class.site.to_s.chomp('/').should == 'https://sso.test.host'
  end

  it 'should preset format' do
    described_class.format.should == ActiveResource::Formats::JsonFormat
  end

  it 'should set token in headers using secret' do
    Bsm::Sso::Client.verifier.stub :generate => "TOKEN"
    described_class.headers.should == {"AUTHORIZATION"=>"TOKEN"}
  end

end
