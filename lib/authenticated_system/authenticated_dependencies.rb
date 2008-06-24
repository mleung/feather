dependency 'merb_helpers'

base = File.dirname(__FILE__)

%w(authenticated_routes authenticated_system_controller authenticated_system_model authenticated_system_orm_map).each do |f|
  require File.join(base, f)
end
