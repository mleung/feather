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
  after_create :set_create_activity
  after_update :set_update_activity
  after_destroy :remove

  ##
  # This grabs the plugin using its url, and loads the metadata for it
  def download
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
    # Load the plugin
    self.load
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
  # This removes the plugin, and adds an activity to show a plugin has been deleted
  def remove
    FileUtils.rm_rf(self.path)
    a = Activity.new
    a.message = "Plugin \"#{self.name}\" deleted"
    a.save
  end
  
  ##
  # This loads the plugin, first loading any gems it may have
  def load
    # Setup the Gem path to the plugin
    Gem.use_paths(Gem.dir, ((Gem.path - [Gem.dir]) + [self.path]))
    # Load the plugin init script
    require File.join(self.path, "init.rb")
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