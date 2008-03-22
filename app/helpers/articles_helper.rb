module Merb
  module ArticlesHelper
    def render_title
      @settings.nil? ? "My Cool Blog" : @settings.title
    end
    
    def render_tag_line
      @settings.nil? ? "This blog rocks hard!" : @settings.tag_line
    end
  end
end