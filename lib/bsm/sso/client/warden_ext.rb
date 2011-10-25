class Warden::SessionSerializer

  def serialize(record)
    record.id
  end

  def deserialize(id)
    Bsm::Sso::Client.user_class.find_for_sso(id)
  end

end
