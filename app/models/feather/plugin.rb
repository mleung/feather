require "fileutils"

module Feather
  class Plugin
    attr_accessor :name, :version, :author, :author_name, :author_email, :author_homepage, :homepage, :about
    
    attr_reader :path
    
    def initialize(plugin = nil)
      if plugin
        @path = Merb.root / "app" / "plugins" / plugin
        manifest = YAML::load_file(File.join(self.path, 'manifest.yml'))
        @name = manifest["name"]
        @version = manifest["version"]
        @homepage = manifest["homepage"]
        @author = manifest["author"]
        if @author
          @author_name = @author["name"]
          @author_email = @author["email"]
          @author_homepage = @author["homepage"]
        end
        @about = manifest["about"]
      end
    end
    
    def id
      self.name
    end
    
    def errors
      DataMapper::Validate::ValidationErrors.new
    end
    
    def destroy
      FileUtils.rm_rf(self.path) unless self.path.nil?
      Feather::Hooks.remove_plugin_hooks(self.id)
    end

    ##
    # This loads the plugin, first loading any gems it may have
    def load
      # Plugin dependencies let you load a plugin before this one,
      # so we don't want to load that sucker twice, now do we?
      unless loaded?
        # Setup the Gem path to the plugin
        Gem.use_paths(Gem.dir, ((Gem.path - [Gem.dir]) + [self.path]))
        # Load the plugin init script
        Kernel.load(File.join(self.path, "init.rb"))
        # Add the plugin to the array of loaded plugins
        @@loaded << self.name
      end
    end

    ##
    # This returns true if the plugin has been loaded, false otherwise
    def loaded?
      @@loaded.include?(self.name)
    end
    
    # This retrieves whether or not the plugin is active
    def active
      active = Feather::PluginSetting.read("active", self)
      !active.nil? && (active == "true" || active == true || active == 1 || active == "1")
    end
    
    # This sets the plugin to be active
    def active=(value)
      Feather::PluginSetting.write("active", (value == "true" || value == true || value == 1 || value == "1"), self)
    end
    
    # This uses the ID (name) as the param for routes etc
    def to_param
      self.id
    end

    class << self
      @@loaded = []
      
      # This returns all plugins found
      def all
        if File.exists?(Merb.root / "app" / "plugins")
          # Grab all plugin folders
          @plugins = Dir.open(Merb.root / "app" / "plugins").
            reject { |file| ['.', '..'].include?(file) }.
            select { |file| File.directory?(File.join(Merb.root / "app" / "plugins", file)) }.
            collect { |file| Feather::Plugin.new(file) }
          @plugins.sort { |a, b| a.name <=> b.name }
        else
          @plugins = []
        end
      end
      
      # This returns all plugins found that are active
      def active
        self.all.select { |p| p.active }
      end
    
      # This retrieves a plugin with the specified name
      def get(plugin)
        path = File.join(Merb.root / "app" / "plugins", plugin)
        if File.exists?(path)
          return Feather::Plugin.new(plugin)
        else
          raise "Plugin not found"
        end
      end
      
      # This method executes the block provided, and if an exception is thrown by that block, will re-raise
      # it with the specified message - good for trapping lots of code with more friendly error messages
      def run_or_error(message, &block)
        yield
      rescue
        raise message
      end

      ##
      # This grabs the plugin using its url, unpacks it, and loads the metadata for it
      def install(manifest_url)
        # Load the manifest yaml
        manifest = run_or_error("Unable to access manifest!") do
          YAML::load(Net::HTTP.get(::URI.parse(url)))
        end
        # Build the path
        path = run_or_error("Unable to build plugin path!") do
          File.join(Merb.root, "app", "plugins", manifest[:name])
        end
        # Remove any existing plugin at the path
        run_or_error("Unable to remove existing plugin path!") do
          FileUtils.rm_rf(path)
        end
        # Create new plugin path
        run_or_error("Unable to create new plugin path!") do
          FileUtils.mkdir_p(path)
        end
        # Download the package
        package = run_or_error("Unable to retrieve package!") do
          package_url = File.join(url.split('/').slice(0..-2).join('/'), manifest[:package])
          Net::HTTP.get(::URI.parse(package_url))
        end
        # Unzip the package
        run_or_error("Unable to unpack zipped plugin package!") do
          Archive::Tar::Minitar.unpack(Zlib::GzipReader.new(StringIO.new(package)), path)
        end
        # Unpack any gems downloaded
        run_or_error("Unable to unpack gems provided by the plugin package!") do
          unpack_gems(Dir.glob(File.join(path, "gems", "*.gem")).collect { |p| p.split("/").last })
        end
        
        # Grab the plugin
        plugin = run_or_error("Cannot instantiate the plugin!") do
          Feather::Plugin.new(manifest[:name])
        end
        
        # Load the plugin
        run_or_error("Cannot load the plugin!") do
          plugin.load
        end
        
        # Install the plugin
        run_or_error("Cannot install the plugin!") do
          load File.join(path, "install.rb") if File.exists?(File.join(path, "install.rb"))
        end
        
        # Return the plugin
        plugin
      end

      ##
      # This recursively unpacks the gems used by the plugin
      def unpack_gems(gems)
        gems.each do |gem|
          # Unpack the gem
          `cd #{File.join(self.path, "gems")}; gem unpack #{File.join(File.join(self.path, "gems"), gem)}`
        end
      end
    end
  end
end