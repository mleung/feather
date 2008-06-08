class Configuration
  include DataMapper::Resource

  property :id, Integer, :key => true, :serial => true
  property :title, String
  property :tag_line, String, :length => 255
  # TODO: was TEXT, is VARCHAR now, should be TEXT again
  property :about, String
  property :about_formatter, String
  property :permalink_format, String

  after :save, :set_activity
  before :save, :prepend_slash_on_permalink

  def set_activity
    a = Activity.new
    a.message = "Configuration updated"
    a.save
  end
  
  def prepend_slash_on_permalink
    self.permalink_format = '/' + self.permalink_format if !self.permalink_format.nil? && self.permalink_format.index('/') != 0
  end

  ##
  # This returns a shortened about for displaying on the settings screen, if the about is multiple lines
  def about_summary
    summary = self.about
    unless summary.nil? || summary.empty?
      summary = summary.gsub("\r\n", "\n")
      summary = "#{summary[0..summary.index("\n") - 1]}..." if summary.index("\n")
      summary = summary.gsub(/"/, "'")
    end
    summary
  end

  ##
  # This returns the current configuration, creating the record if it isn't found
  def self.current
    configuration = Configuration.first
    configuration = Configuration.create(:title => "My new Feather blog", :tag_line => "Feather rocks!", :about => "I rock, and so does my Feather blog", :about_formatter => "default", :permalink_format => "/:year/:month/:day/:title") if configuration.nil?
    configuration    
  end
end