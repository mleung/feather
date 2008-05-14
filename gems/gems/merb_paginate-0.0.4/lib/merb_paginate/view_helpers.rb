# This file is very merb specific, but it only includes the ViewHelpers module if merb is already loaded

require 'merb_paginate/core_ext'

module MerbPaginate
  # = MerbPaginate view helpers
  #
  # Currently there is only one view helper: +merb_paginate+. It renders the
  # pagination links for the given collection. The helper itself is lightweight
  # and serves only as a wrapper around link renderer instantiation; the
  # renderer then does all the hard work of generating the HTML.
  # 
  # == Global options for helpers
  #
  # Options for pagination helpers are optional and get their default values from the
  # MerbPaginate::ViewHelpers.pagination_options hash. You can write to this hash to
  # override default options on the global level:
  #
  #   MerbPaginate::ViewHelpers.pagination_options[:prev_label] = 'Previous page'
  #
  # By putting this into your init.rb you can easily translate link texts to previous
  # and next pages, as well as override some other defaults to your liking.
  module ViewHelpers
    # default options that can be overridden on the global level
    @@pagination_options = {
      :class        => 'pagination',
      :prev_label   => '&laquo; Previous',
      :next_label   => 'Next &raquo;',
      :inner_window => 4, # links around the current page
      :outer_window => 1, # links around beginning and end
      :separator    => ' ', # single space is friendly to spiders and non-graphic browsers
      :param_name   => :page,
      :params       => nil,
      :renderer     => 'MerbPaginate::LinkRenderer',
      :page_links   => true,
      :container    => true,
      :namespace    => nil
    }
    
    # there is not mattr_accessor here and it's not a big deal to just make these two getter/setter methods for now
    
    def self.pagination_options
      @@pagination_options
    end
    
    def self.pagination_options=(options)
      @@pagination_options = options
    end

    # Renders Digg/Flickr-style pagination for a MerbPaginate::Collection
    # object. Nil is returned if there is only one page in total; no point in
    # rendering the pagination in that case...
    # 
    # ==== Options
    # * <tt>:class</tt> -- CSS class name for the generated DIV (default: "pagination")
    # * <tt>:prev_label</tt> -- default: "« Previous"
    # * <tt>:next_label</tt> -- default: "Next »"
    # * <tt>:inner_window</tt> -- how many links are shown around the current page (default: 4)
    # * <tt>:outer_window</tt> -- how many links are around the first and the last page (default: 1)
    # * <tt>:separator</tt> -- string separator for page HTML elements (default: single space)
    # * <tt>:param_name</tt> -- parameter name for page number in URLs (default: <tt>:page</tt>)
    # * <tt>:params</tt> -- additional parameters when generating pagination links
    #   (eg. <tt>:controller => "foo", :action => nil</tt>)
    # * <tt>:renderer</tt> -- class name of the link renderer (default: WillPaginate::LinkRenderer)
    # * <tt>:page_links</tt> -- when false, only previous/next links are rendered (default: true)
    # * <tt>:container</tt> -- toggles rendering of the DIV container for pagination links, set to
    #   false only when you are rendering your own pagination markup (default: true)
    # * <tt>:id</tt> -- HTML ID for the container (default: nil). Pass +true+ to have the ID automatically
    #   generated from the class name of objects in collection: for example, paginating
    #   ArticleComment models would yield an ID of "article_comments_pagination".
    #
    # All options beside listed ones are passed as HTML attributes to the container
    # element for pagination links (the DIV). For example:
    # 
    #   <%= merb_paginate @posts, :id => 'wp_posts' %>
    #
    # ... will result in:
    #
    #   <div class="pagination" id="wp_posts"> ... </div>
    #
    # There is not magic controller inference anynmore. Pass in the variable lazy.
    #
    def merb_paginate(collection, options = {}) # collection is required now! Booya!
      # early exit if there is nothing to render
      return nil unless collection.total_pages > 1
      
      options = options.to_mash.reverse_merge MerbPaginate::ViewHelpers.pagination_options.to_mash
      # create the renderer instance
      renderer_class = options[:renderer].to_s.constantize
      renderer = renderer_class.new collection, options, self
      # render HTML for pagination
      renderer.to_html
    end
    
    # Wrapper for rendering pagination links at both top and bottom of a block
    # of content.
    # 
    #   <% paginated_section @posts do %>
    #     <ol id="posts">
    #       <% for post in @posts %>
    #         <li> ... </li>
    #       <% end %>
    #     </ol>
    #   <% end %>
    #
    # will result in:
    #
    #   <div class="pagination"> ... </div>
    #   <ol id="posts">
    #     ...
    #   </ol>
    #   <div class="pagination"> ... </div>
    #
    # Arguments are passed to a <tt>will_paginate</tt> call, so the same options
    # apply. Don't use the <tt>:id</tt> option; otherwise you'll finish with two
    # blocks of pagination links sharing the same ID (which is invalid HTML).
    def paginated_section(*args, &block)
      pagination = merb_paginate(*args).to_s
      content = pagination + capture(&block) + pagination
      #concat content, block.binding
      content
    end
    
    # Renders a helpful message with numbers of displayed vs. total entries.
    # You can use this as a blueprint for your own, similar helpers.
    #
    #   <%= page_entries_info @posts %>
    #   #-> Displaying entries 6 - 10 of 26 in total
    def page_entries_info(collection)
      if collection.total_pages < 2
        case collection.size
        when 0; 'No entries found'
        when 1; 'Displaying <b>1</b> entry'
        else;   "Displaying <b>all #{collection.size}</b> entries"
        end
      else
        %{Displaying entries <b>%d&nbsp;-&nbsp;%d</b> of <b>%d</b> in total} % [
          collection.offset + 1,
          collection.offset + collection.length,
          collection.total_entries
        ]
      end
    end
    
  end

  # Copied mostly from will_paginate, but changed to work with the merb url helpers
  class LinkRenderer

    def initialize(collection, options, template)
      @collection = collection
      @options    = options
      @template   = template
    end

    def to_html
      links = @options[:page_links] ? windowed_links : []
      # previous/next buttons
      links.unshift page_link_or_span(@collection.previous_page, 'disabled', @options[:prev_label])
      links.push    page_link_or_span(@collection.next_page,     'disabled', @options[:next_label])
      
      html = links.join(@options[:separator])
      @options[:container] ? "<div#{html_attributes_string}>#{html}</div>" : html
    end

    def html_attributes
      return @html_attributes if @html_attributes
      @html_attributes = @options.except *(MerbPaginate::ViewHelpers.pagination_options.keys - [:class])
      # pagination of Post models will have the ID of "posts_pagination"
      if @options[:container] and @options[:id] === true
        @html_attributes[:id] = @collection.first.class.name.underscore.pluralize + '_pagination'
      end
      @html_attributes
    end
    
    def html_attributes_string
      string = ""
      if html_attributes
        html_attributes.each do |key, value|
          string << " #{key}='#{value}'"
        end
      end
      string
    end
    
  protected

    def gap_marker; '...'; end
    
    def windowed_links
      prev = nil

      visible_page_numbers.inject [] do |links, n|
        # detect gaps:
        links << gap_marker if prev and n > prev + 1
        links << page_link_or_span(n)
        prev = n
        links
      end
    end

    def visible_page_numbers
      inner_window, outer_window = @options[:inner_window].to_i, @options[:outer_window].to_i
      window_from = current_page - inner_window
      window_to = current_page + inner_window
      
      # adjust lower or upper limit if other is out of bounds
      if window_to > total_pages
        window_from -= window_to - total_pages
        window_to = total_pages
      elsif window_from < 1
        window_to += 1 - window_from
        window_from = 1
      end
      
      visible   = (1..total_pages).to_a
      left_gap  = (2 + outer_window)...window_from
      right_gap = (window_to + 1)...(total_pages - outer_window)
      visible  -= left_gap.to_a  if left_gap.last - left_gap.first > 1
      visible  -= right_gap.to_a if right_gap.last - right_gap.first > 1

      visible
    end
    
    def page_link_or_span(page, span_class = 'current', text = nil)
      text ||= page.to_s
      if page and page != current_page
        "<a href=\"#{url_options_string(page)}\">#{text}</a>"
      else
        "<span class=\"#{span_class}\">#{text}</span>"
      end
    end

    # TODO: I am not sure if I like the way this is working. It will always do /posts/index?page=1 for page one when it could do /
    # Would be nice if it was smarter
    def url_options(page)
      options = { param_name => page }
      # page links should preserve GET parameters
      options = @template.request.params.merge(options).except('action', 'controller', 'format', *Array(@options[:except])) if @template.request.method == :get
      options.rec_merge!(@options[:params]) if @options[:params]
      return options
    end
    
    def url_options_string(page)
      @template.url(url_options(page))
      if @options[:namespace].nil?
        @template.url(url_options(page))
      else
        @template.url(@options[:namespace], url_options(page))
      end
    end

  private

    def current_page
      @collection.current_page
    end

    def total_pages
      @collection.total_pages
    end

    def param_name
      @param_name ||= @options[:param_name].to_sym
    end

    def params
      @params ||= @template.params.to_mash
    end
  end
end

if Object.const_defined? "Merb"
  Merb::Controller.class_eval do
    include MerbPaginate::ViewHelpers
  end
end
