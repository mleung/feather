module Admin
  class Base < Application
    layout :admin
    before :login_required
  end
end