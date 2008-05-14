# someone please show me some love :(

require 'merb_paginate/finders/generic'

module MerbPaginate
  module Finders
    
    module Datamapper
      def self.included(base)
        base.extend ClassMethods
        class << base
          define_method(:per_page) { 30 } unless respond_to?(:per_page)
        end
      end

      module ClassMethods
        include MerbPaginate::Finders::GenericOrmMethods # include the things that are shared
        
        def paginate(options = {})
          Merb.logger.info(" $$$ Sequel support in merb_paginate has not been tested at all. Please let me know if it works.")
          page, per_page, total_entries = wp_parse_options(options)

          WillPaginate::Collection.create(page, per_page, total_entries) do |pager|
            count_options = options.except :page, :per_page, :total_entries
            find_options = count_options.except(:count).update(:offset => pager.offset, :limit => pager.per_page) 
      
            pager.replace all(find_options)
      
            # magic counting for user convenience:
            pager.total_entries = wp_count(count_options) unless pager.total_entries
          end
        end

      end
    end
    
  end
end