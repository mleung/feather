class MaMigrationGenerator < Merb::GeneratorBase
  
  attr_accessor :plural_name, :single_name, :time_stamp
  
  def initialize(runtime_args, runtime_options = {})
    @base = File.dirname(__FILE__)
    super
    @name = args.shift
  end
  
  def manifest
    record do |m|
      @m = m

      @table_name = @name.split("::").last.snake_case.singularize.pluralize
      
      @assigns = {
        :time_stamp => @time_stamp,
        :class_name => @name,
        :table_name => @table_name
      }
      
      copy_dirs
      copy_files
    end
    
  end
  
    protected
      def banner
        <<-EOS
  Creates a migration for merb-auth user model

  USAGE: #{$0} #{spec.name} name"
  EOS
      end
  
end
