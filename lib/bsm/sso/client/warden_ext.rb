class Warden::SessionSerializer

  def serialize(record)
    record.id
  end

  def deserialize(id)
    Bsm::Sso::Client.user_class.sso_find(id)
  end

end
