# $Id$
require 'rubygems'
require 'rake'
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

# Many of these tasks came from the ruby-hl7 project rakefile

desc 'Default: run unit tests.'
task :default => :test

# Gem Specification
spec = Gem::Specification.new do |s| 
  s.name = short_name
  s.full_name
  s.version = HL7::VERSION
  s.author = "Mark Guzman"
  s.email = "segfault@hasno.info"
  s.homepage = "http://rubyforge.org/ruby-hl7"
  s.platform = Gem::Platform::RUBY
  s.summary = "Ruby HL7 Library"
  s.rubyforge_project = short_name
  s.description = "A simple library to parse and generate HL7 2.x messages"
  s.files = FileList["{bin,lib,test_data}/**/*"].to_a
  s.require_path = "lib"
  s.autorequire = short_name
  s.test_files = FileList["{test}/**/test*.rb"].to_a
  s.has_rdoc = true
  s.extra_rdoc_files = %w[README LICENSE]
  s.add_dependency("rake", ">= #{RAKEVERSION}")
  s.add_dependency("rubyforge", ">= #{::RubyForge::VERSION}")
end

# Gem Task
Rake::GemPackageTask.new(spec) do |pkg| 
  pkg.need_tar = true 
end

# Test Task
Rake::TestTask.new do |t|
  t.test_files = FileList[ 'test/test*.rb', 'test/*test.rb' ]
  t.verbose = true
end

namespace :test do
  desc 'Measures test coverage'
  task :coverage do
    rm_f "coverage"
    rm_f "coverage.data"
    rcov = "rcov --aggregate coverage.data --text-summary -Ilib"
    system("#{rcov} --html test/test*.rb")
    system("open coverage/index.html") if PLATFORM['darwin']
  end
  
  desc 'Heckle the tests'
  task :heckle do
    system("heckle HL7::Message")
  end

  desc 'Show which test files fail when run alone.'
  task :deps do
    tests = Dir["test/**/test_*.rb"]  +  Dir["test/**/*_test.rb"]

    tests.each do |test|
      if not system "ruby -Ibin:lib:test #{test} &> /dev/null" then
        puts "Dependency Issues: #{test}"
      end
    end
  end
end
 

# Clean up Task
desc 'Clean up all the extras'
task :clean => [ :clobber_rdoc, :clobber_package ] do
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