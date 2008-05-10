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
        
        # This is the main paginating finder.
        #
        # == Special parameters for paginating finders
        # * <tt>:page</tt> -- REQUIRED, but defaults to 1 if false or nil
        # * <tt>:per_page</tt> -- defaults to <tt>CurrentModel.per_page</tt> (which is 30 if not overridden)
        # * <tt>:total_entries</tt> -- use only if you manually count total entries
        # * <tt>:count</tt> -- additional options that are passed on to +count+
        #
        # All other options (+conditions+, +order+, ...) are forwarded to +all+
        # and +count+ calls.
        def paginate(options = {})
          page, per_page, total_entries = wp_parse_options(options)

          WillPaginate::Collection.create(page, per_page, total_entries) do |pager|
            count_options = options.except :page, :per_page, :total_entries
            find_options = count_options.except(:count).update(:offset => pager.offset, :limit => pager.per_page) 
      
            pager.replace all(find_options)
      
            # magic counting for user convenience:
            pager.total_entries = wp_count(count_options) unless pager.total_entries
          end
        end
  
        # Wraps +find_by_sql+ by simply adding LIMIT and OFFSET to your SQL string
        # based on the params otherwise used by paginating finds: +page+ and
        # +per_page+.
        #
        # Example:
        # 
        #   @developers = Developer.paginate_by_sql ['select * from developers where salary > ?', 80000],
        #                          :page => params[:page], :per_page => 3
        #
        # A query for counting rows will automatically be generated if you don't
        # supply <tt>:total_entries</tt>. If you experience problems with this
        # generated SQL, you might want to perform the count manually in your
        # application.
        # 
        # def paginate_by_sql(sql, options)
        #   WillPaginate::Collection.create(*wp_parse_options(options)) do |pager|
        #     query = sanitize_sql(sql)
        #     original_query = query.dup
        #     # add limit, offset
        #     add_limit! query, :offset => pager.offset, :limit => pager.per_page
        #     # perfom the find
        #     pager.replace find_by_sql(query)
        #     
        #     unless pager.total_entries
        #       count_query = original_query.sub /\bORDER\s+BY\s+[\w`,\s]+$/mi, ''
        #       count_query = "SELECT COUNT(*) FROM (#{count_query}) AS count_table"
        #       # perform the count query
        #       pager.total_entries = count_by_sql(count_query)
        #     end
        #   end
        # end
  
        # ^^^^^
        # FIXME: Too busy to do this right now, someone help me out

        # def respond_to?(method, include_priv = false) #:nodoc:
        #   case method.to_sym
        #   when :paginate, :paginate_by_sql
        #     true
        #   else
        #     super(method, include_priv)
        #   end
        # end
  
        # ^^^^^
        # FIXME: Probly don't need this?

      end
    end
    
  end
end