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
require "dm-core"
use_orm :datamapper

use_test :test_unit
# use_test :rspec

require 'config/dependencies.rb'

Merb::BootLoader.before_app_loads do
  Dir.glob("app/models/*/*.rb").each { |f| require f }
  Merb::Authentication.user_class = Feather::User
  
  Merb::Slices.config[:merb_auth] = {
    :layout => :admin,
    :login_field => :login
  }
  
  require "tzinfo"
  require "net/http"
  require "uri"
  require "cgi"
  require "erb"
  require "zlib"
  require "stringio"
  require "archive/tar/minitar"
  require File.join("lib", "feather", "padding")
  require File.join("lib", "feather", "hooks")
  require File.join("lib", "feather", "database")
  require File.join("lib", "feather", "plugin_dependencies")
  require File.join("lib", "merb_auth_setup")
end

Merb::BootLoader.after_app_loads do
  Merb::Mailer.delivery_method = :sendmail
end

# require File.join(File.join(Merb.root_path, "lib"), "cache_helper")

# Merb::Plugins.config[:merb_cache] = {
#   :cache_html_directory => Merb.dir_for(:public)  / "cache",
#   :store => "file",
#   :cache_directory => Merb.root_path("tmp/cache"),
#   :disable => "development"
# }