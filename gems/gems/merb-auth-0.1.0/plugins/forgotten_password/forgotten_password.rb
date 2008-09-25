if MerbAuth[:forgotten_password] && MerbAuth[:user]
  dir = File.expand_path(File.dirname(__FILE__))
  Dir[File.join(dir, "app", "**/*.rb")].each{ |f| require f }  
end

#########################  Include it into the module man