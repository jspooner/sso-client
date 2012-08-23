require 'spec_helper'

describe Bsm::Sso::Client::Cached::ActiveRecord do

  subject do
    User.new
  end

  after do
    User.delete_all
  end

  let :record do
    User.create!({:id => 100, :email => "alice@example.com", :kind => "user", :level => 10, :authentication_token => "SECRET"}, :as => :sso)
  end

  def resource(attrs = {})
    Bsm::Sso::Client::User.new record.attributes.merge(attrs)
  end

  let :new_resource do
    Bsm::Sso::Client::User.new :id => 200, :email => "new@example.com"
  end

  it { should be_a(described_class) }
  it { should validate_presence_of(:id) }

  [:id, :email, :kind, :level, :authentication_token].each do |attribute|
    it { should allow_mass_assignment_of(attribute).as(:sso) }
    it { should_not allow_mass_assignment_of(attribute) }
  end

  it 'should not error on mass-assignment errors' do
    subject.class._mass_assignment_sanitizer.should be_instance_of(ActiveModel::MassAssignmentSecurity::LoggerSanitizer)
    lambda { subject.assign_attributes({ inaccessible: true }, as: :sso) }.should_not raise_error
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

  it 'should not authorize blank tokens' do
    Bsm::Sso::Client::User.should_not_receive(:sso_authorize)
    User.sso_authorize(" ").should be_nil
  end

  it 'should authorize as usual when user is not cached' do
    Bsm::Sso::Client::User.should_receive(:sso_authorize).and_return(nil)
    User.sso_authorize("SECRET").should be_nil
  end

  it 'should used cached on authorize' do
    record # Create one
    Bsm::Sso::Client::User.should_not_receive(:sso_authorize)
    User.sso_authorize("SECRET").should == record
  end

  it 'should not use cached on authorize when expired' do
    record.update_column :updated_at, 3.hours.ago
    Bsm::Sso::Client::User.should_receive(:sso_authorize).and_return(nil)
    User.sso_authorize("SECRET").should be_nil
  end

  it 'should cache (and create) new records' do
    record = User.sso_cache(new_resource)
    record.should be_a(User)
    record.should be_persisted
    record.id.should == 200
  end

  it 'should cache (and update) existing records when changed' do
    lambda {
      User.sso_cache(resource(:level => 20)).should == record
    }.should change { record.reload.level }.from(10).to(20)
  end

  it 'should cache (and touch) existing records even when unchanged' do
    lambda {
      User.sso_cache(resource).should == record
    }.should change { record.reload.updated_at }
  end

end
