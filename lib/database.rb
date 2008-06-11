module Database
  class << self
    CORE = Dir.glob("app/models/*.rb").collect { |s| Class.const_get(s.split("/").last.gsub(".rb", "").split("_").collect { |w| w.capitalize }.join("")) }
    
    # This provides a helper method for data migration for plugins - we can then update this to use non-destructive migrations at a later date and existing plugins won't need to change
    def migrate(klass)
      # Validate
      raise "Unable to perform migrations, class must be specified!" unless klass.class == Class
      raise "Unable to perform migrations for core class!" if CORE.include?(klass)
      raise "Class cannot be migrated!" unless klass.respond_to?(:auto_migrate!)
      # Execute auto migrations for now
      klass.auto_migrate!
    end
    
    # This does the initial auto migration of all core classes
    def initial_setup
      CORE.each { |c| c.auto_migrate! }
    end
  end
end