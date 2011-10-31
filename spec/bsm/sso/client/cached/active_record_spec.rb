require 'spec_helper'

describe Bsm::Sso::Client::Cached::ActiveRecord do

  subject do
    User.new
  end

  after do
    User.delete_all
  end

  let :record do
    User.create!({:id => 100, :email => "alice@example.com", :kind => "user", :level => 10}, :as => :sso)
  end

  let :resource do
    Bsm::Sso::Client::User.new record.attributes.merge(:level => 20)
  end

  let :new_resource do
    Bsm::Sso::Client::User.new :id => 200, :email => "new@example.com"
  end

  it { should be_a(described_class) }
  it { should validate_presence_of(:id) }

  [:id, :email, :kind, :level].each do |attribute|
    it { should allow_mass_assignment_of(attribute).as(:sso) }
    it { should_not allow_mass_assignment_of(attribute) }
  end

  it 'should accept IDs as parameters' do
    User.new({ :id => '123' }, :as => :sso).id.should == 123
    User.new({ :id => '123' }, :as => :sso).should_not be_persisted
  end

  it 'should find records' do
    User.sso_find(record.id).should == record
    Bsm::Sso::Client::User.should_receive(:sso_find).with(-1).and_return(nil)
    User.sso_find(-1).should be_nil
  end

  it 'should cache (and create) new records' do
    record = User.sso_cache(new_resource)
    record.should be_a(User)
    record.should be_persisted
    record.id.should == 200
  end

  it 'should cache (and update) existing records' do
    lambda {
      User.sso_cache(resource).should == record
    }.should change { record.reload.level }.from(10).to(20)
  end

end
