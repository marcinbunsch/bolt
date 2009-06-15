# This Rakefile has been copied from mislav/rspactor
# Mislav, you rock, did I tell you this already? :)

task :default => :spec

desc "starts Bolt"
task :spec do
  system "ruby -Ilib bin/bolt"
end

desc "generates .gemspec file"
task :gemspec => "version:read" do
  spec = Gem::Specification.new do |gem|
    gem.name = "bolt"
    gem.summary = "Bolt is a merge of autotest and mislav/rspactor to produce a lightning fast, configurable and simple to set up autotest clone"
    gem.email = "marcin@applicake.com"
    gem.homepage = "http://github.com/marcinbunsch/bolt"
    gem.authors = ["Marcin Bunsch", "Mislav Marohnić"]
    gem.has_rdoc = false
    
    gem.version = GEM_VERSION
    gem.files = FileList['Rakefile', '{bin,lib,images,spec}/**/*', 'README*', 'LICENSE*']
    gem.executables = Dir['bin/*'].map { |f| File.basename(f) }
  end
  
  spec_string = spec.to_ruby
  
  begin
    Thread.new { eval("$SAFE = 3\n#{spec_string}", binding) }.join 
  rescue
    abort "unsafe gemspec: #{$!}"
  else
    File.open("#{spec.name}.gemspec", 'w') { |file| file.write spec_string }
  end
end

desc "bump the version up"
task :bump => ["version:bump", :gemspec]

desc "reinstall the gem locally"
task :reinstall do
  GEM_VERSION = File.read("VERSION")
  system('sudo gem uninstall bolt')
  system("gem build bolt.gemspec")
  system("sudo gem install bolt-#{GEM_VERSION}.gem")
end

namespace :version do
  task :read do
    unless defined? GEM_VERSION
      if File.exists?('VERSION')
        GEM_VERSION = File.read("VERSION")
      else
        GEM_VERSION = '0.0.1'
      end
    end
  end
  
  desc "bump the version up"
  task :bump => :read do
    if ENV['VERSION']
      GEM_VERSION.replace ENV['VERSION']
    else
      GEM_VERSION.sub!(/\d+$/) { |num| num.to_i + 1 }
    end
    
    File.open("VERSION", 'w') { |v| v.write GEM_VERSION }
  end
end

task :release => :bump do
  system %(git commit VERSION *.gemspec -m "release v#{GEM_VERSION}")
  system %(git tag -am "release v#{GEM_VERSION}" v#{GEM_VERSION})
end
