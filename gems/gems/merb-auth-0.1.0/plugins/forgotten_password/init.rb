MerbAuth.plugins[:forgotten_password] = File.join(File.expand_path(File.dirname(__FILE__)) / "forgotten_password.rb")

MA.add_routes do |r|
  if MerbAuth[:forgotten_password] && MerbAuth[:user]
    r.match("/passwords/edit").to(:controller => "Passwords", :action => "edit").name(:merb_auth_edit_password_form)
    r.match("/passwords", :method => :put).to(:controller => "Passwords", :action => "update")
    r.resources :passwords
  end
end