# Make the app's "gems" directory a place where gems are loaded from
Gem.clear_paths
Gem.path.unshift(Merb.root / "gems")

# Make the app's "lib" directory a place where ruby files get "require"d from
$LOAD_PATH.unshift(Merb.root / "lib")

Merb::Config.use do |c|
  
  ### Sets up a custom session id key, if you want to piggyback sessions of other applications
  ### with the cookie session store. If not specified, defaults to '_session_id'.
  # c[:session_id_key] = '_session_id'
  
  c[:session_secret_key]  = '95bf50e5bb36b2a455611792c271f2581e6b21db'
  c[:session_store] = 'datamapper'
  c[:use_mutex] = false
  c[:logfile] = Merb.log_path + "/merb.log"
  
end

### Merb doesn't come with database support by default.  You need
### an ORM plugin.  Install one, and uncomment one of the following lines,
### if you need a database.

### Uncomment for DataMapper ORM
use_orm :datamapper

### Uncomment for ActiveRecord ORM
# use_orm :activerecord

### Uncomment for Sequel ORM
# use_orm :sequel


### This defines which test framework the generators will use
### rspec is turned on by default
###
### Note that you need to install the merb_rspec if you want to ue
### rspec and merb_test_unit if you want to use test_unit. 
### merb_rspec is installed by default if you did gem install
### merb.
###
use_test :test_unit
# use_test :rspec

### Add your other dependencies here

# These are some examples of how you might specify dependencies.
# 
gem "archive-tar-minitar"
dependency "merb-helpers"
dependency "merb-assets"
# dependency "merb-cache"
dependency "merb-action-args"
dependency "merb_has_flash"
dependency "merb-mailer"
dependency "merb-slices"
dependency "merb-auth"
dependency "merb-auth-slice-password"
dependency "merb-auth-core"
dependency "merb-auth-more"
dependency "dm-aggregates"
dependency "dm-validations"
dependency "dm-timestamps"
dependency "merb_paginate"

# OR
# OR
# dependencies "RedCloth" => "> 3.0", "ruby-aes-cext" => "= 1.0"

Merb::BootLoader.before_app_loads do
  Merb::Slices.config[:merb_auth] = {
    :layout => :admin,
    :login_field => :login
  }
end

Merb::BootLoader.after_app_loads do
  require "tzinfo"
  require "net/http"
  require "uri"
  require "cgi"
  require "erb"
  require "zlib"
  require "stringio"
  require "archive/tar/minitar"
  require File.join("lib", "padding")
  require File.join("lib", "hooks")
  require File.join("lib", "database")
  require File.join("lib", "plugin_dependencies")

  # This loads the plugins
  begin
    Plugin.all(:order => [:name]).each do |p|
      begin
        p.load
        Merb.logger.info("\"#{p.name}\" loaded")
      rescue Exception => e
        Merb.logger.info("\"#{p.name}\" failed to load : #{e.message}")
      end
    end
  rescue Exception => e
    Merb.logger.info("Error loading plugins: #{e.message}")
  end
#  raise "You must specify a valid openid in Merb.root/config/openid to use this example app" unless File.exists?(Merb.root / "config" / "open_id")
  DataMapper.auto_migrate!
  User.create(:login => "admin", 
              :name => "admin",
              :email => "admin@example.com", 
              :password => "password", :password_confirmation => "password", 
              :time_zone => "Europe/London",
              :active => true,
 #             :identity_url => File.read(Merb.root / "config" / "open_id"),
              :time_zone => "Europe/London")

  Merb::Mailer.delivery_method = :sendmail
end

# require File.join(File.join(Merb.root_path, "lib"), "cache_helper")

# Merb::Plugins.config[:merb_cache] = {
#   :cache_html_directory => Merb.dir_for(:public)  / "cache",
#   :store => "file",
#   :cache_directory => Merb.root_path("tmp/cache"),
#   :disable => "development"
# }

