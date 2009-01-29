module Feather
  module Admin
    class Base < Feather::Application
      layout :admin
      before :ensure_authenticated
    end
  end
end