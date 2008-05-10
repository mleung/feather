require 'set'
require 'will_paginate/array'

# copied from rails
def mattr_reader(*syms)
  syms.each do |sym|
    next if sym.is_a?(Hash)
    class_eval("unless defined? @@\#{sym}\n@@\#{sym} = nil\nend\n\ndef self.\#{sym}\n@@\#{sym}\nend\n\ndef \#{sym}\n@@\#{sym}\nend\n", __FILE__, __LINE__)
  end
end

def returning(value)
  yield(value)
  value
end

# copied from will_paginate
unless Hash.instance_methods.include? 'except'
  Hash.class_eval do
    # Returns a new hash without the given keys.
    def except(*keys)
      rejected = Set.new(respond_to?(:convert_key) ? keys.map { |key| convert_key(key) } : keys)
      reject { |key,| rejected.include?(key) }
    end
 
    # Replaces the hash without only the given keys.
    def except!(*keys)
      replace(except(*keys))
    end
  end
end

unless Hash.instance_methods.include? 'reverse_merge'
  Hash.class_eval do
    def reverse_merge(other_hash)
      other_hash.merge(self)
    end
  end
end

unless Hash.instance_methods.include? 'slice'
  Hash.class_eval do
    # Returns a new hash with only the given keys.
    def slice(*keys)
      allowed = Set.new(respond_to?(:convert_key) ? keys.map { |key| convert_key(key) } : keys)
      reject { |key,| !allowed.include?(key) }
    end

    # Replaces the hash with only the given keys.
    def slice!(*keys)
      replace(slice(*keys))
    end
  end
end

unless Hash.instance_methods.include? 'rec_merge!'
  Hash.class_eval do
    # Same as Hash#merge!, but recursively merges sub-hashes
    # (stolen from Haml)
    def rec_merge!(other)
      other.each do |key, other_value|
        value = self[key]
        if value.is_a?(Hash) and other_value.is_a?(Hash)
          value.rec_merge! other_value
        else
          self[key] = other_value
        end
      end
      self
    end
  end
end

class String
  
  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
  
  def constantize
    unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ self
      raise NameError, "#{self.inspect} is not a valid constant name!"
    end

    Object.module_eval("::#{$1}", __FILE__, __LINE__)
  end
  
end