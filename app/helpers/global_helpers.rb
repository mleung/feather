module Merb
  module GlobalHelpers
    def render_title
      @settings.nil? ? "My Cool Blog" : @settings.title
    end

    def render_tag_line
      @settings.nil? ? "This blog rocks hard!" : @settings.tag_line
    end
  
    def render_text(formatter, text)
      Hooks::Formatters.format_text(formatter, text)
    end
    
    def render_article(article)
      Hooks::Formatters.format_article(article)
    end
    
    def render_menu
      menu = ""
      menu_items.each_with_index do |item, index|
      	menu += "<li>#{link_to item[:text], item[:url]} #{render_link_dot(index, menu_items.size - 1)}</li>"
      end
      menu
    end
    
    # TODO: merb is supposed ot have a built in lib for this. Use it.
    def render_relative_date(date)
      date = Date.parse(date, true) unless /Date.*/ =~ date.class.to_s
      days = (date - Date.today).to_i

      return 'today' if days >= 0 and days < 1
      return 'tomorrow' if days >= 1 and days < 2
      return 'yesterday' if days >= -1 and days < 0

      return "in #{days} days" if days.abs < 60 and days > 0
      return "#{days.abs} days ago" if days.abs < 60 and days < 0

      return date.strftime('%A, %B %e') if days.abs < 182
      return date.strftime('%A, %B %e, %Y')
    end

    def notifications
      notifications = session[:notifications]
      session[:notifications] = nil
      notifications
    end
    
    def get_timezones
      TZInfo::Timezone.all.collect { |tz| tz.name }
    end
    
    def render_relative_published_at(article)
      article.published_at.nil? ? "Not yet" : render_relative_date(TZInfo::Timezone.get(logged_in? ? self.current_user.time_zone : article.user.time_zone).utc_to_local(article.published_at))
    end
    
    def render_about_text
      unless @settings.nil? || @settings.about.blank?
        markup = <<-MARKUP
        <div class="sidebar-node">
          <h3>About</h3>
          <p>#{render_text(@settings.about_formatter, @settings.about)}</p>
        </div>
        MARKUP
      end
      markup
    end
    
    def year_url(year)
      url(:year, {:year => year})
    end
    
    def month_url(year, month)
      url(:month, {:year => year, :month => Padding::pad_single_digit(month)})
    end
    
    def day_url(year, month, day)
      url(:day, {:year => year, :month => Padding::pad_single_digit(month), :day => Padding::pad_single_digit(day)})
    end

    ##
    # This returns all items, including those provided by plugins
    def menu_items
      items = []
      items << {:text => "Dashboard", :url => url(:admin_dashboard)}
      items << {:text => "Articles", :url => url(:admin_articles)}
      items << {:text => "Plugins", :url => url(:admin_plugins)}
      items << {:text => "Settings", :url => url(:admin_configurations)}
      items << {:text => "Users", :url => url(:admin_users)}
      if self.current_user == :false
        items << {:text => "Login", :url => url(:login)}
      else
        items << {:text => "Logout", :url => url(:logout)}
      end
      Hooks::Menu.menu_items.each { |item| items << item }
      items
    end
    
    def render_link_dot(index, collection_size)
      "&nbsp;•" unless index == collection_size
    end
    
    ##
    # This renders all plugin views for the specified hook
    def render_plugin_views(name, options = {})
      output = ""
      Hooks::View.plugin_views.each do |view|
        if view[:name] == name
          if view[:partial]
            _template_root = File.join(view[:plugin].path, "views")
            template_location = _template_root / _template_location("_#{view[:partial]}", content_type, view[:name])
            template_method = Merb::Template.template_for(template_location)
            output << send(template_method, options)
          else
            output << Proc.new { |args| ERB.new(view[:content]).result(binding) }.call(options[:with])
          end
        end
      end
      output
    end
    
    ##
    # This returns the full url for an article
    def get_full_url(article)
      "http://#{request.host}#{article.permalink}"
    end
    
    ##
    # This escapes the specified url
    def escape_url(url)
      CGI.escape(url)
    end
    
    ##
    # This returns true if the specified plugin is active, false if it isn't, or is unavailable
    def is_plugin_active(name)
      plugin = Plugin.first(:name => name)
      plugin && plugin.active
    end
  end
end