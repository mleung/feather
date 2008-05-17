# Allows you to tell a plugin it depends on another, and will load the dependency first.
# Usage: PluginDependencies::register_dependency "feather-comments" in init.rb of your plugin.
module PluginDependencies
 class << self
   def register_dependency(dependency)
     p = Plugin.first(:name => dependency)
     raise ArgumentError, "Plugin dependency: '#{dependency}' not installed" if p.nil?
     p.load unless p.loaded?
   end
  end
end