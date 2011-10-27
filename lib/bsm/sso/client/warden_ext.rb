class Warden::SessionSerializer
  # Stores user id and expiration time
  def serialize(record)
    [record.id, record.expires_at]
  end

  # Loads user and expiration time from session
  def deserialize(values)
    id, expires_at = values
    user = Bsm::Sso::Client.user_class.sso_find(id)
    user.expires_at = expires_at
    user
  end
end

# Hook on session fetching
Warden::Manager.after_fetch do |user, auth, opts|
  scope = opts[:scope]

  if Time.now > user.expires_at
    auth.logout(scope)
    throw(:warden, :scope => scope, :reason => "Times Up")
  end
end
