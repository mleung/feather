module Merb
  module GlobalHelpers
    
    def textile_to_html(content)
      RedCloth.new(content).to_html
    end
    
    # TODO: merb is supposed ot have a built in lib for this. Use it.
    def render_relative_date(date)
      date = Date.parse(date, true) unless /Date.*/ =~ date.class.to_s
      days = (date - Date.today).to_i

      return 'today'     if days >= 0 and days < 1
      return 'tomorrow'  if days >= 1 and days < 2
      return 'yesterday' if days >= -1 and days < 0

      return "in #{days} days"      if days.abs < 60 and days > 0
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
      unless @settings.nil? || @settings.blank?
        markup = <<-MARKUP
        <div class="sidebar-node">
          <h3>About</h3>
          <p>#{@settings.about}</p>
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
  end
end