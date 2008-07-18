class User
  include MerbAuth::Adapter::DataMapper
  include MerbAuth::Adapter::DataMapper::DefaultModelSetup

  property :time_zone,                  String
  property :name,                       String
  property :default_formatter,          String

  after :save, :set_create_activity
  after :save, :set_update_activity

  def set_create_activity
    if new_record?
      a = Activity.new
      a.message = "User \"#{self.login}\" created"
      a.save
    end
  end

  def set_update_activity
    unless new_record?
      a = Activity.new
      a.message = "User \"#{self.login}\" updated"
      a.save
    end
  end
end
