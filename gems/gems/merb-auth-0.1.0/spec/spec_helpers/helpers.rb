class String
  def self.random(length = 10)
    @__avail_chars ||= (('a'..'z').to_a << ("A".."Z").to_a).flatten
    (1..length).inject(""){|out, index| out << @__avail_chars[rand(@__avail_chars.size)]}
  end
end

class Hash
  
  def with( opts )
    self.merge(opts)
  end
  
  def without(*args)
    self.dup.delete_if{ |k,v| args.include?(k)}
  end
  
end