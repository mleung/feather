$SLICED_APP=true # we're running inside the host application context

namespace :slices do
  namespace :merb_auth do
  
    desc "Install MerbAuth"
    task :install => [:preflight, :setup_directories, :copy_assets, :migrate]
    
    desc "Test for any dependencies"
    task :preflight do # see slicetasks.rb
    end
  
    desc "Setup directories"
    task :setup_directories do
      puts "Creating directories for host application"
      MerbAuth.mirrored_components.each do |type|
        if File.directory?(MerbAuth.dir_for(type))
          if !File.directory?(dst_path = MerbAuth.app_dir_for(type))
            relative_path = dst_path.relative_path_from(Merb.root)
            puts "- creating directory :#{type} #{File.basename(Merb.root) / relative_path}"
            mkdir_p(dst_path)
          end
        end
      end
    end
    
    desc "Copy stub files to host application"
    task :stubs do
      puts "Copying stubs for MerbAuth - resolves any collisions"
      copied, preserved = MerbAuth.mirror_stubs!
      puts "- no files to copy" if copied.empty? && preserved.empty?
      copied.each { |f| puts "- copied #{f}" }
      preserved.each { |f| puts "! preserved override as #{f}" }
    end
    
    desc "Copy stub files and views to host application"
    task :patch => [ "stubs", "freeze:views" ]
  
    desc "Copy public assets to host application"
    task :copy_assets do
      puts "Copying assets for MerbAuth - resolves any collisions"
      copied, preserved = MerbAuth.mirror_public!
      puts "- no files to copy" if copied.empty? && preserved.empty?
      copied.each { |f| puts "- copied #{f}" }
      preserved.each { |f| puts "! preserved override as #{f}" }
    end
    
    desc "Migrate the database"
    task :migrate do # see slicetasks.rb
    end
    
    desc "Freeze MerbAuth into your app (only merb-auth/app)" 
    task :freeze => [ "freeze:app" ]

    namespace :freeze do
      
      desc "Freezes MerbAuth by installing the gem into application/gems using merb-freezer"
      task :gem do
        begin
          Object.const_get(:Freezer).freeze(ENV["GEM"] || "merb-auth", ENV["UPDATE"], ENV["MODE"] || 'rubygems')
        rescue NameError
          puts "! dependency 'merb-freezer' missing"
        end
      end
      
      desc "Freezes MerbAuth by copying all files from merb-auth/app to your application"
      task :app do
        puts "Copying all merb-auth/app files to your application - resolves any collisions"
        copied, preserved = MerbAuth.mirror_app!
        puts "- no files to copy" if copied.empty? && preserved.empty?
        copied.each { |f| puts "- copied #{f}" }
        preserved.each { |f| puts "! preserved override as #{f}" }
      end
      
      desc "Freeze all views into your application for easy modification" 
      task :views do
        puts "Copying all view templates to your application - resolves any collisions"
        copied, preserved = MerbAuth.mirror_files_for :view
        puts "- no files to copy" if copied.empty? && preserved.empty?
        copied.each { |f| puts "- copied #{f}" }
        preserved.each { |f| puts "! preserved override as #{f}" }
      end
      
      desc "Freeze all models into your application for easy modification" 
      task :models do
        puts "Copying all models to your application - resolves any collisions"
        copied, preserved = MerbAuth.mirror_files_for :model
        puts "- no files to copy" if copied.empty? && preserved.empty?
        copied.each { |f| puts "- copied #{f}" }
        preserved.each { |f| puts "! preserved override as #{f}" }
      end
      
      desc "Freezes MerbAuth as a gem and copies over merb-auth/app"
      task :app_with_gem => [:gem, :app]
      
      desc "Freezes MerbAuth by unpacking all files into your application"
      task :unpack do
        puts "Unpacking MerbAuth files to your application - resolves any collisions"
        copied, preserved = MerbAuth.unpack_slice!
        puts "- no files to copy" if copied.empty? && preserved.empty?
        copied.each { |f| puts "- copied #{f}" }
        preserved.each { |f| puts "! preserved override as #{f}" }
      end
      
    end
    
    desc "Run slice specs within the host application context"
    task :spec => [ "spec:explain", "spec:default" ]
    
    namespace :spec do
      
      slice_root = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
      
      task :explain do
        puts "\nNote: By running MerbAuth specs inside the application context any\n" +
             "overrides could break existing specs. This isn't always a problem,\n" +
             "especially in the case of views. Use these spec tasks to check how\n" +
             "well your application conforms to the original slice implementation."
      end
      
      Spec::Rake::SpecTask.new('default') do |t|
        t.spec_opts = ["--format", "specdoc", "--colour"]
        t.spec_files = Dir["#{slice_root}/spec/**/*_spec.rb"].sort
      end

      desc "Run all model specs, run a spec for a specific Model with MODEL=MyModel"
      Spec::Rake::SpecTask.new('model') do |t|
        t.spec_opts = ["--format", "specdoc", "--colour"]
        if(ENV['MODEL'])
          t.spec_files = Dir["#{slice_root}/spec/models/**/#{ENV['MODEL']}_spec.rb"].sort
        else
          t.spec_files = Dir["#{slice_root}/spec/models/**/*_spec.rb"].sort
        end
      end

      desc "Run all controller specs, run a spec for a specific Controller with CONTROLLER=MyController"
      Spec::Rake::SpecTask.new('controller') do |t|
        t.spec_opts = ["--format", "specdoc", "--colour"]
        if(ENV['CONTROLLER'])
          t.spec_files = Dir["#{slice_root}/spec/controllers/**/#{ENV['CONTROLLER']}_spec.rb"].sort
        else    
          t.spec_files = Dir["#{slice_root}/spec/controllers/**/*_spec.rb"].sort
        end
      end

      desc "Run all view specs, run specs for a specific controller (and view) with CONTROLLER=MyController (VIEW=MyView)"
      Spec::Rake::SpecTask.new('view') do |t|
        t.spec_opts = ["--format", "specdoc", "--colour"]
        if(ENV['CONTROLLER'] and ENV['VIEW'])
          t.spec_files = Dir["#{slice_root}/spec/views/**/#{ENV['CONTROLLER']}/#{ENV['VIEW']}*_spec.rb"].sort
        elsif(ENV['CONTROLLER'])
          t.spec_files = Dir["#{slice_root}/spec/views/**/#{ENV['CONTROLLER']}/*_spec.rb"].sort
        else
          t.spec_files = Dir["#{slice_root}/spec/views/**/*_spec.rb"].sort
        end
      end

      desc "Run all specs and output the result in html"
      Spec::Rake::SpecTask.new('html') do |t|
        t.spec_opts = ["--format", "html"]
        t.libs = ['lib', 'server/lib' ]
        t.spec_files = Dir["#{slice_root}/spec/**/*_spec.rb"].sort
      end
      
    end
    
  end
end