class Configuration < DataMapper::Base
  property :title, :string
  property :tag_line, :string
  property :about, :string
  
  # This returns a shortened about for displaying on the settings screen, if the about is multiple lines
  def about_summary
    summary = self.about
    summary = summary.gsub("\r\n", "\n")
    summary = "#{summary[0..summary.index("\n") - 1]}..." if summary.index("\n")
    summary
  end
end