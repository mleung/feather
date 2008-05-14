require 'rubygems'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'spec/rake/spectask'

PLUGIN = "merb_paginate"
NAME = "merb_paginate"
GEM_VERSION = "0.0.4"
AUTHOR = "Nathan Herald"
EMAIL = "nathan@myobie.com"
HOMEPAGE = "http://github.com/myobie/merb_paginate"
SUMMARY = "A pagination library for Merb that uses will_paginate internally"

windows = (PLATFORM =~ /win32|cygwin/)

SUDO = windows ? "" : "sudo"

spec = Gem::Specification.new do |s|
  s.name = NAME
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "LICENSE", 'TODO']
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  s.add_dependency("merb-core", ">=0.9")
  s.add_dependency("will_paginate", ">=2.2.0")
  s.require_path = 'lib'
  s.autorequire = PLUGIN
  s.files = %w(LICENSE README Rakefile TODO) + Dir.glob("{lib,specs}/**/*")
end


Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Run :package and install resulting .gem"
task :install => [:package] do
  sh %{#{SUDO} gem install pkg/#{NAME}-#{GEM_VERSION} --no-rdoc --no-ri}
end

Rake::RDocTask.new do |rdoc|
      files = ['README', 'LICENSE',
               'lib/**/*.rb']
      rdoc.rdoc_files.add(files)
      rdoc.main = 'README'
      rdoc.title = 'Merb Helper Docs'
      rdoc.rdoc_dir = 'doc/rdoc'
      rdoc.options << '--line-numbers' << '--inline-source'
end


Spec::Rake::SpecTask.new do |t|
   t.warning = true
   t.spec_opts = ["--format", "specdoc", "--colour"]
   t.spec_files = Dir['spec/**/*_spec.rb'].sort   
end

desc "Run all specs and generate an rcov report"
Spec::Rake::SpecTask.new('rcov') do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ["--format", "specdoc", "--colour"]
  t.rcov = true
  t.rcov_dir = 'coverage'
  t.rcov_opts = ['--exclude', 'gems', '--exclude', 'spec']
end


