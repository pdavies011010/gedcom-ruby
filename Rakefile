# $Id$
require 'rubygems'
require 'rake'
require 'spec/rake/spectask'
require 'rake/testtask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/contrib/sshpublisher'
require 'rbconfig'
require 'rubyforge'

$: << './lib'
require 'gedcom'
full_name = "GEDCOM-Ruby"
short_name = full_name.downcase

#
# Many of these tasks came from the ruby-hl7 project rakefile
#

desc 'Default: Run RSpec Tests' 
task :default => :spec

# Gem Specification
spec = Gem::Specification.new do |s| 
  s.name = short_name
  s.version = GEDCOM::VERSION
  s.author = "Phillip Davies"
  s.email = "fcdradio@gmail.com"
  # Need to get the RubyForge project set up  !!! PCD
  s.homepage = "http://rubyforge.org/ruby-hl7"
  s.platform = Gem::Platform::RUBY
  s.summary = "Ruby GEDCOM Parser Library"
  s.rubyforge_project = short_name
  s.description = "A simple library to enable the parsing of GEDCOM data files" 
  s.files = FileList["{lib,ext,samples,tests}/**/*"].to_a
  s.require_path = "lib"
  s.autorequire = short_name
  s.test_files = FileList["{tests}/**/*_spec.rb"].to_a
  s.has_rdoc = false
  s.extra_rdoc_files = %w[README COPYING]
  s.add_dependency("rake", ">= #{RAKEVERSION}")
  s.add_dependency("rubyforge", ">= #{::RubyForge::VERSION}")
end

# Gem Task
Rake::GemPackageTask.new(spec) do |pkg| 
  pkg.need_tar = true 
  pkg.package_dir_path = "pkg/"
end

# RSpec Test Task
desc 'Run all RSpec tests'
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['tests/*_spec.rb']
end

namespace :spec do
  desc 'Run all RSpec tests with RCov to measure coverage'
  Spec::Rake::SpecTask.new('spec_with_rcov') do |t|
    t.warning = true
    t.spec_files = FileList['tests/*_spec.rb']
    t.rcov = true
  end
  
  desc 'Heckle the tests'
  task :heckle do
    system("spec tests/*_spec.rb --heckle GEDCOM::DatePart")
    system("spec tests/*_spec.rb --heckle GEDCOM::Date")
  end
end
 

# Clean up Task
desc 'Clean up all the extras'
task :clean => [ :clobber_package ] do
  %w[*.gem ri coverage*].each do |pattern|
    files = Dir[pattern]
    rm_rf files unless files.empty?
  end
end

# Release task (package and upload to Ruby Forge)
desc 'Package and upload the release to rubyforge.'
task :release => [:clean, :package] do |t|
  v = ENV["VERSION"] or abort "Must supply VERSION=x.y.z"
  abort "Versions don't match '#{v}' vs '#{spec.version}'" if v != spec.version.to_s
  pkg = "pkg/#{spec.name}-#{spec.version}"

  if $DEBUG then
    puts "release_id = rf.add_release #{spec.rubyforge_project.inspect}, #{spec.name.inspect}, #{version.inspect}, \"#{pkg}.tgz\""
    puts "rf.add_file #{spec.rubyforge_project.inspect}, #{spec.name.inspect}, release_id, \"#{pkg}.gem\""
  end

  rf = RubyForge.new
  puts "Logging in"
  rf.login

  changes = open("NOTES").readlines.join("") if File.exists?("NOTES")
  c = rf.userconfig
  c["release_notes"] = spec.description if spec.description
  c["release_changes"] = changes if changes
  c["preformatted"] = true

  files = ["#{pkg}.tgz", "#{pkg}.gem"].compact

  puts "Releasing #{spec.name} v. #{spec.version}"
  rf.add_release spec.rubyforge_project, spec.name, spec.version.to_s, *files
end

# Task to install the gem locally 
desc 'Install the package as a gem'
task :install_gem => [:clean, :package] do
  sh "sudo gem install pkg/*.gem"
end
