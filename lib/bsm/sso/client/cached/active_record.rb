require 'active_record/base'
require 'active_support/concern'

module Bsm::Sso::Client::Cached::ActiveRecord
  extend  ActiveSupport::Concern
  include Bsm::Sso::Client::UserMethods

  included do
    validates       :id, :presence => true, :on => :create
    attr_accessible :id, :email, :kind, :level, :as => :sso
  end

  module ClassMethods

    # Retrieve cached
    def sso_find(id)
      where(:id => id).first || super
    end

    # Cache!
    def sso_cache(resource, action = nil)
      if record = where(:id => resource.id).first
        record.update_attributes! resource.attributes, :as => :sso
        record
      else
        create! resource.attributes, :as => :sso
      end
    end

  end
end