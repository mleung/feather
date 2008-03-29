module Merb
  module Orms
    module DataMapper
      class << self
        alias connect_old connect
        
        def connect
          connect_old
          @after_connect.call unless @after_connect.nil?
        end
        
        def after_connect(&block)
          @after_connect = block
        end
      end
    end
  end
end