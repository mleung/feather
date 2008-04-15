class Configuration < DataMapper::Base
  property :title, :string
  property :tag_line, :string, :length => 255
  property :about, :text
  property :about_formatter, :string
  
  after_save :set_activity
  
  def set_activity
    a = Activity.new
    a.message = "Configuration updated"
    a.save
  end
  
  # This returns a shortened about for displaying on the settings screen, if the about is multiple lines
  def about_summary
    summary = self.about
    unless summary.nil? || summary.empty?
      summary = summary.gsub("\r\n", "\n")
      summary = "#{summary[0..summary.index("\n") - 1]}..." if summary.index("\n")
      summary
    end
  end
  
  ##
  # This returns the current configuration, creating them if they aren't found
  def self.current
    configuration = Configuration.first
    configuration = Configuration.create(:title => "My new blog", :tag_line => "My blog rocks!", :about => "I rock, and so does my blog", :about_formatter => "default") if configuration.nil?
    configuration    
  end
end