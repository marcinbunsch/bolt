require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "bolt"
    gem.summary = %q{Bolt is a merge of autotest, mislav/rspactor and rails_server_testing to produce a lightning fast, configurable and simple to set up autotest clone.}
    gem.authors = ["Marcin Bunsch"]
    gem.email = "marcin@applicake.com"
    gem.homepage = "http://github.com/marcinbunsch/bolt"
    gem.executables = Dir['bin/*'].map { |f| File.basename(f) }
    gem.files = FileList['.bolt', '.document', '.bolt.sample', 'Rakefile', '{bin,lib,images,spec}/**/*', 'README*', 'LICENSE*']
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end

rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

desc 'Run the gem locally'
task :run do
  system('ruby -I lib bin/bolt')
end

desc 'Reinstall the gem locally'
task :reinstall do
  f = File.open('VERSION')
  version = f.read.gsub("\n", '')
  f.close
  system("sudo gem uninstall bolt")
  system("gem build bolt.gemspec")
  system("sudo gem install bolt-#{version}.gem")
  system("rm bolt-#{version}.gem")
end


task :default => :run

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "bolt #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

