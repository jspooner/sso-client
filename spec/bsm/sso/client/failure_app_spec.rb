require 'spec_helper'

describe Bsm::Sso::Client::FailureApp do

  let :env do
    env_with_params.merge("warden.options" => { :attempted_path => '/' })
  end

  let :response do
    ActionDispatch::TestResponse.new *described_class.call(env)
  end

  describe "for HTML requests" do

    it "should redirect to SSO" do
      response.code.should == "303"
      response.location.should == "https://sso.test.host/sign_in?service=http%3A%2F%2Fexample.org%2F"
    end

  end

  describe "for API requests" do

    let :env do
      env_with_params "/", :format => "json"
    end

    it "should fail with 403" do
      lambda { response }.should raise_error(Bsm::Sso::Client::UnauthorizedAccess)
    end

  end

  describe "for XHR requests" do

    let :env do
      env_with_params "/", { :format => "js" }, { "HTTP_X_REQUESTED_WITH" => "XMLHttpRequest" }
    end

    it "should respond with JS" do
      response.code.should == "200"
      response.content_type.should == Mime::JS
      response.body.should include("alert(")
    end

  end

end
