module Merb
  module GlobalHelpers
    
    def textile_to_html(content)
      RedCloth.new(content).to_html
    end

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

  end
end