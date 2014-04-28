require 'spec_helper'

describe Bsm::Sso::Client::Cached::ActiveRecord do

  before do
    I18n.enforce_available_locales = false
  end

  subject do
    User.new
  end

  after do
    User.delete_all
    I18n.enforce_available_locales = true
  end

  let :record do
    args = [{id: 100, email: "alice@example.com", kind: "user", level: 10, authentication_token: "SECRET"}]
    args << {without_protection: true} if defined?(ProtectedAttributes)
    User.create! *args
  end

  def resource(attrs = {})
    Bsm::Sso::Client::User.new record.attributes.merge(attrs)
  end

  let :new_resource do
    Bsm::Sso::Client::User.new id: 200, email: "new@example.com"
  end

  it { should be_a(described_class) }
  it { should validate_presence_of(:id) }

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
      User.sso_cache(resource(level: 20)).should == record
    }.should change { record.reload.level }.from(10).to(20)

    lambda {
      User.sso_cache(resource("level" => 10)).should == record
    }.should change { record.reload.level }.from(20).to(10)
  end

  it 'should cache (and touch) existing records even when unchanged' do
    lambda {
      User.sso_cache(resource).should == record
    }.should change { record.reload.updated_at }
  end

  it 'should only cache known attributes' do
    lambda {
      User.sso_cache(resource(unknown: "value")).should == record
    }.should change { record.reload.updated_at }
  end

  it 'should only cache known attributes for new records' do
    record.destroy
    lambda {
      User.sso_cache(resource(unknown: "value"))
    }.should_not raise_error
  end

end
