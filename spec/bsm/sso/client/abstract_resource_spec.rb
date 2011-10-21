require 'spec_helper'

describe Bsm::Sso::Client::AbstractResource do

  it 'should use site from configuration' do
    described_class.site.to_s.should == 'https://sso.test.host/'
  end

  it 'should preset format' do
    described_class.format.should == ActiveResource::Formats::JsonFormat
  end

  it 'should set token in headers using secret' do
    Time.stub! :now => Time.at(0)
    described_class.headers.should == {"AUTHORIZATION"=>"BAhJdToJVGltZQ0ggBGAAADgAQc6C0Bfem9uZUkiCEJTVAY6BkVUOgtvZmZzZXRpAhAO--053a0134a0e1105fb0bc933be01bf7b092473331"}
  end

end
