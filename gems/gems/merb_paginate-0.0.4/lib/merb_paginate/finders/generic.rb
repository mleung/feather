module MerbPaginate
  module Finders
    
    # A mixin for ORMs. Provides +per_page+ class method
    module GenericOrmMethods
      protected
      
      # Count it up!
      def wp_count(options)
        excludees = [:count, :order, :limit, :offset, :readonly]
      
        # unless options[:select] and options[:select] =~ /^\s*DISTINCT\b/i
        #   excludees << :select # only exclude the select param if it doesn't begin with DISTINCT
        # end
      
        # ^^^^^^
        # FIXME: Don't need select right now and I'm not even sure how it works in datamapper to be honest
      
        # count expects the same options as find
        count_options = options.except *excludees
        
        # merge the hash found in :count
        # this allows you to specify :select, :order, or anything else just for the count query
        count_options.update options[:count] if options[:count]
        
        # !IMPORTANT!: this assumes all ORMs will have a count method
        # if this assumtion turns out to be false, I will move this into the specific ORM finders
        counter = count_options.empty? ? count : count(count_options) # don't pass in nothing (helps datamapper 0.2.5 and maybe others)
        counter.respond_to?(:length) ? counter.length : counter # send back the length of the resulting count (either the length of the array or the number returned)
      end
      
      def wp_parse_options(options) #:nodoc:
        raise ArgumentError, 'parameter hash expected' unless options.is_a? Hash
        options = options.to_mash # FIXME: where is this defined? I don't want to use anything that is not part of core_ext.rb
        raise ArgumentError, ':page parameter required' unless options.key? :page # TODO: it's set as a default below, why is it needed here?
      
        if options[:count] and options[:total_entries]
          raise ArgumentError, ':count and :total_entries are mutually exclusive'
        end

        page     = options[:page] || 1
        per_page = options[:per_page] || self.per_page
        total    = options[:total_entries]
        [page, per_page, total]
      end

    end
  
  end
end
