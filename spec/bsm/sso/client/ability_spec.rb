require 'spec_helper'

describe Bsm::Sso::Client::Ability do

  class Bsm::Sso::Client::TestAbility
    include Bsm::Sso::Client::Ability

    as :client, "main:role" do
    end

    as :client, "sub:role" do
      same_as "main:role"
    end

    as :client, "other:role" do
    end

    as :employee, "other:role" do
    end

  end

  let :user do
    ::User.new.tap do |u| 
      u.level = 0
      u.roles = ["sub:role"]
    end
  end

  subject do
    Bsm::Sso::Client::TestAbility.new(user)
  end

  describe "class" do
    subject { Bsm::Sso::Client::TestAbility }

    it { should have(2).roles }
    its(:roles) { should be_instance_of(Hash) }
    its(:roles) { subject.keys.should =~ [:employee, :client] }
    its(:roles) { subject[:employee].should have(1).item }
    its(:roles) { subject[:client].should have(3).items }

    it 'should define role methods' do
      subject.should have(4).private_instance_methods(false)
      subject.private_instance_methods(false).should include(:"as__client__main:role")
    end
  end

  its(:scope) { should == :client }
  its(:applied) { should == ["main:role", "sub:role"].to_set }

  it 'should apply roles only once' do
    subject.same_as("main:role").should be(false)
    subject.same_as("sub:role").should be(false)
    subject.same_as("other:role").should be(true)
  end

  it 'should not allow role application from different scopes' do
    subject.send("as__employee__other:role").should be(false)
    subject.send("as__client__other:role").should be(true)
  end

end