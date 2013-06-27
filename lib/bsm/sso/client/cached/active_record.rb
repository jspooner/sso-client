require 'active_record/base'
require 'active_support/concern'

module Bsm::Sso::Client::Cached::ActiveRecord
  extend  ActiveSupport::Concern
  include Bsm::Sso::Client::UserMethods

  included do
    validates       :id, presence: true, on: :create
  end

  module ClassMethods

    # Retrieve cached
    def sso_find(id)
      where(id: id).first || super
    end

    # Cache!
    def sso_authorize(token)
      return nil if token.blank?

      relation = where(arel_table[:updated_at].gt(Bsm::Sso::Client.expire_after.ago))
      relation = relation.where(authentication_token: token)
      relation.first || super
    end

    # Cache!
    def sso_cache(resource, action = nil)
      if record = where(id: resource.id).first
        record.assign_attributes(resource.attributes)
        record.changed? ? record.save! : record.touch
        record
      else
        create!(resource.attributes)
      end
    end

  end
end