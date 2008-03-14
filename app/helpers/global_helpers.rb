module Merb
  module GlobalHelpers
    
    def textile_to_html(content)
      r = RedCloth.new(content)
      r.to_html
    end
    
  end
end