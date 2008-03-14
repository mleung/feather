module UserSpecHelper
  def valid_user_hash
    { :login                  => "daniel",
      :email                  => "daniel@example.com",
      :password               => "sekret",
      :password_confirmation  => "sekret"}
  end
end