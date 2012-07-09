require 'spec_helper'

describe Bsm::Sso::Client::AbstractResource do

  subject do
    described_class.new "email" => "noreply@example.com"
  end

  before do
    Bsm::Sso::Client.verifier.stub :generate => "TOKEN"
  end

  it 'should use site from configuration' do
    site = described_class.site
    site.should be_instance_of(Excon::Connection)
    site.connection[:host].should == "sso.test.host"
    site.connection[:idempotent].should be(true)
    site.connection[:headers].should == { "Accept"=>"application/json", "Content-Type"=>"application/json" }
  end

  it 'should set default headers using secret' do
    headers = described_class.headers
    headers.should == {"Authorization"=>"TOKEN"}
  end

  it 'should get remote records' do
    request = stub_request(:get, "https://sso.test.host/users/123?b=2").
      with(:headers => {
        'Accept'=>'application/json',
        'Authorization'=>'TOKEN',
        'Content-Type'=>'application/json',
        'Host'=>'sso.test.host:443',
        'a' => 1
      }).to_return :status => 200, :body => %({ "id": 123 })

    result  = described_class.get("/users/123", :headers => { 'a' => 1 }, :query => { 'b' => 2 })
    result.should be_instance_of(described_class)
    result.should == { "id" => 123 }
    result.id.should == 123
  end

  it { should be_a(Hash) }
  it { should respond_to(:email) }
  it { should_not respond_to(:name) }
  its(:email) { should == "noreply@example.com" }
  its(:attributes) { should be_instance_of(described_class) }
  its(:attributes) { should == {"email"=>"noreply@example.com"} }

  it 'can be blank' do
    described_class.new.should == {}
  end

end
