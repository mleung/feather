class Plugin

  include DataMapper::Resource

  property :id, Integer, :key => true
  property :url, String, :length => 255
  property :path, String, :length => 255
  property :name, String
  property :author, String
  property :version, String
  property :homepage, String, :length => 255
  property :about, String, :length => 255
  property :active, TrueClass

  before :save, :download
  after :save, :install
  after :save, :set_create_activity
  after :save, :set_update_activity
  after :destroy, :remove

  class << self
    @@loaded = []
  end

  ##
  # This grabs the plugin using its url, unpacks it, and loads the metadata for it
  def download
    if new_record?
      # Load the manifest yaml
      manifest = YAML::load(Net::HTTP.get(URI.parse(url + "/manifest.yml")))
      # Grab metadata from manifest
      self.name = manifest["plugin"]["name"]
      self.author = manifest["plugin"]["author"]
      self.version = manifest["plugin"]["version"]
      self.homepage = manifest["plugin"]["homepage"]
      self.about = manifest["plugin"]["about"]
      # Build the path
      self.path = File.join(File.join(File.join(Merb.root, "app"), "plugins"), URI.parse(url).path.split("/").last.split(".").first)
      # Remove any existing plugin at the path
      FileUtils.rm_rf(self.path)
      # Download all of the plugin contents
      recurse(manifest["plugin"]["contents"])
      # Unpack any gems downloaded
      unpack_gems(manifest["plugin"]["contents"]["gems"]["."]) unless manifest["plugin"]["contents"]["gems"].nil?
    end
  end

  ##
  # This loads and installs the plugin
  def install
    if new_record?
      # Load the plugin
      self.load
      # Also, if there is an "install.rb" script present, run that to setup anything the plugin needs (database tables etc)
      require File.join(self.path, "install.rb") if File.exists?(File.join(self.path, "install.rb"))
    end
    
  rescue Exception => err
    # Catch the error, delete the plugin, and raise an error again
    self.destroy!
    raise "Error installing plugin: #{err.message}!"
  end

  ##
  # This adds the activity to show a plugin has been installed
  def set_create_activity
    if new_record?
      a = Activity.new
      a.message = "Plugin \"#{self.name}\" installed"
      a.save
    end
  end

  ##
  # This adds the activity to show a plugin has been updated
  def set_update_activity
    unless new_record?
      a = Activity.new
      a.message = "Plugin \"#{self.name}\" #{self.active ? 'activated' : 'de-activated'}"
      a.save
    end
  end

  ##
  # This removes the plugin, de-registers hooks, and adds an activity to show a plugin has been deleted
  def remove
    FileUtils.rm_rf(self.path)
    Hooks.remove_plugin_hooks(self.id)
    a = Activity.new
    a.message = "Plugin \"#{self.name}\" deleted"
    a.save
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
      require File.join(self.path, "init.rb")
      # Add the plugin to the array of loaded plugins
      @@loaded << self.name
    end
  end

  ##
  # This returns true if the plugin has been loaded, false otherwise
  def loaded?
    @@loaded.include?(self.name)
  end

  private
    ##
    # This recursively uses the yaml to download the files specified in the manifest
    def recurse(yaml, base_dir = self.path, base_url = self.url)
      yaml.keys.each do |dir|
        path = (dir == "." ? base_dir : File.join(base_dir, dir))
        url = (dir == "." ? base_url : File.join(base_url, dir))
        case yaml[dir].class.to_s
        when "Array":
          yaml[dir].each do |file|
            FileUtils.mkdir_p(path)
            f = File.open(File.join(path, file), "w")
            f.write(Net::HTTP.get(URI.parse(File.join(url, file))))
            f.close
            f = nil
          end
        when "Hash":
          recurse(yaml[dir], path, url)
        end
      end
    end

    ##
    # This recursively unpacks the gems used by the plugin
    def unpack_gems(gems)
      gems.each do |gem|
        # Unpack the gem
        `gem unpack #{File.join(File.join(self.path, "gems"), gem)}`
        # We can't seem to use --target on the gem command above to actually specify the output folder - so it's in Merb.root; lets move it
        FileUtils.mv gem.gsub(".gem", ""), File.join(File.join(self.path, "gems"), gem.gsub(".gem", ""))
      end
    end
end