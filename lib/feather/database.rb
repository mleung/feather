module Feather
  module Database
    class << self
      CORE = [Feather::Activity, Feather::Article, Feather::Configuration, Feather::Plugin, Feather::PluginSetting, Feather::User]
    
      # This provides a helper method for data migration for plugins - we can then update this to use non-destructive migrations at a later date and existing plugins won't need to change
      def migrate(klass)
        # Validate
        raise "Unable to perform migrations, class must be specified!" unless klass.class == Class
        raise "Unable to perform migrations for core class!" if CORE.include?(klass)
        raise "Class cannot be migrated!" unless klass.respond_to?(:auto_migrate!)
        # Execute auto migrations for now
        klass.auto_migrate!
      end
    
      # This does the initial auto migration of all core classes, as well as the session table
      def initial_setup
        CORE.each { |c| c.auto_migrate! }
        Merb::DataMapperSession.auto_migrate!
      end
    end
  end
end