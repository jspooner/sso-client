require 'spec_helper'

describe Bsm::Sso::Client::FailureApp do

  let :env do
    env_with_params.merge("warden.options" => { attempted_path: '/?a=1&b[]=2&b[]=3' })
  end

  let :response do
    ActionDispatch::TestResponse.new *described_class.call(env)
  end

  describe "for HTML requests" do

    it "should redirect to SSO" do
      response.code.should == "303"
      response.location.should == "https://sso.test.host/sign_in?service=http%3A%2F%2Fexample.org%2F%3Fa%3D1%26b%5B%5D%3D2%26b%5B%5D%3D3"
    end

  end

  describe "for API requests" do

    let :env do
      env_with_params "/", format: "json"
    end

    it "should fail with 403" do
      response.code.should == "403"
      response.content_type.should == Mime::HTML
    end

  end

  describe "for API requests (from browsers)" do

    let :env do
      env_with_params "/?a=1&b[]=2", {format: "json"}, { "HTTP_ACCEPT" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" }
    end

    it "should redirect to SSO" do
      response.code.should == "303"
      response.location.should == "https://sso.test.host/sign_in?service=http%3A%2F%2Fexample.org%2F%3Fa%3D1%26b%5B%5D%3D2%3Fformat%3Djson"
    end

  end

  describe "for XHR requests" do

    let :env do
      env_with_params "/", { format: "js" }, { "HTTP_X_REQUESTED_WITH" => "XMLHttpRequest" }
    end

    it "should respond with JS" do
      response.code.should == "200"
      response.content_type.should == Mime::JS
      response.body.should include("alert(")
    end

  end

end
