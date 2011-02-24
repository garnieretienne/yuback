require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "yuback"
  gem.homepage = "http://github.com/garnieretienne/yuback"
  gem.license = "GPLv3"
  gem.summary = %Q{Another backup tool for web applications}
  gem.description = %Q{
    Yuback is backup tool for web applications.
    It can backup an application fully or partially.
    The configuration can deal with source code, cache folder, framework folder, databases and dynamic files folders.
    The libraries can also be used independently in a ruby script.
  }
  gem.email = "garnier.etienne@gmail.com"
  gem.authors = ["Etienne Garnier (kurt/yuweb)"]

  # Runtime dependencies
  gem.add_development_dependency 'libarchive-ruby-swig', '> 0'
  # Development dependencies
  gem.add_development_dependency "shoulda", ">= 0"
  gem.add_development_dependency "bundler", "> 1.0.0"
  gem.add_development_dependency "jeweler", "> 1.5.2"
  gem.add_development_dependency "rcov", "> 0"
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "test #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
