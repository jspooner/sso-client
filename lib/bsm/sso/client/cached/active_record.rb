require 'active_record/base'
require 'active_support/concern'

module Bsm::Sso::Client::Cached::ActiveRecord
  extend  ActiveSupport::Concern
  include Bsm::Sso::Client::UserMethods

  included do
    validates :id, presence: true, on: :create
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
      record = where(id: resource.id).first_or_initialize
      attrs  = [resource.attributes.slice(*record.attribute_names)]
      attrs << {without_protection: true} if defined?(ProtectedAttributes)
      record.assign_attributes(*attrs)
      record.changed? ? record.save! : record.touch
      record
    end

  end
end
