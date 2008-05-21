class Plugin < DataMapper::Base
  property :url, :string, :length => 255
  property :path, :string, :length => 255
  property :name, :string
  property :author, :string
  property :version, :string
  property :homepage, :string, :length => 255
  property :about, :string, :length => 255
  property :active, :boolean

  before_create :download
  after_create :install
  after_create :set_create_activity
  after_update :set_update_activity
  after_destroy :remove

  class << self
    @@loaded = []
  end

  ##
  # This grabs the plugin using its url, unpacks it, and loads the metadata for it
  def download
    # Load the manifest yaml
    manifest = YAML::load(Net::HTTP.get(URI.parse(url + ".yml")))
    # Grab metadata from manifest
    self.name = manifest["name"]
    self.author = manifest["author"]
    self.version = manifest["version"]
    self.homepage = manifest["homepage"]
    self.about = manifest["about"]
    # Build the path
    self.path = File.join(File.join(File.join(Merb.root, "app"), "plugins"), URI.parse(url).path.split("/").last.split(".").first)
    # Remove any existing plugin at the path
    FileUtils.rm_rf(self.path)
    Dir.mkdir(self.path)
    # Download the package and untgz
    require 'zlib'
    require 'stringio'
    require 'archive/tar/minitar'
    package = Net::HTTP.get(URI.parse(url + ".tgz"))
    Archive::Tar::Minitar.unpack(Zlib::GzipReader.new(StringIO.new(package)), self.path)
    # Unpack any gems downloaded
    unpack_gems(manifest["gems"]["."]) unless manifest["gems"].nil?
  end

  ##
  # This loads and installs the plugin
  def install
    # Load the plugin
    self.load
    # Also, if there is an "install.rb" script present, run that to setup anything the plugin needs (database tables etc)
    require File.join(self.path, "install.rb") if File.exists?(File.join(self.path, "install.rb"))
  rescue Exception => err
    # Catch the error, delete the plugin, and raise an error again
    self.destroy!
    raise "Error installing plugin: #{err.message}!"
  end

  ##
  # This adds the activity to show a plugin has been installed
  def set_create_activity
    a = Activity.new
    a.message = "Plugin \"#{self.name}\" installed"
    a.save
  end

  ##
  # This adds the activity to show a plugin has been updated
  def set_update_activity
    a = Activity.new
    a.message = "Plugin \"#{self.name}\" #{self.active ? 'activated' : 'de-activated'}"
    a.save
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
        `cd #{File.join(self.path, "gems")}; gem unpack #{File.join(File.join(self.path, "gems"), gem)}`
      end
    end
end