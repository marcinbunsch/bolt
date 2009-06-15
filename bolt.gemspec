# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{bolt}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Marcin Bunsch", "Mislav Marohni\304\207"]
  s.date = %q{2009-06-15}
  s.default_executable = %q{bolt}
  s.email = %q{marcin@applicake.com}
  s.executables = ["bolt"]
  s.files = ["Rakefile", "bin/bolt", "lib/bolt", "lib/bolt/listener.rb", "lib/bolt/listeners", "lib/bolt/listeners/generic.rb", "lib/bolt/listeners/osx.rb", "lib/bolt/notifier.rb", "lib/bolt/notifiers", "lib/bolt/notifiers/generic.rb", "lib/bolt/notifiers/growl.rb", "lib/bolt/runner.rb", "lib/bolt/runners", "lib/bolt/runners/rspec.rb", "lib/bolt/runners/test_unit.rb", "lib/bolt.rb", "images/failed.png", "images/LICENSE", "images/pending.png", "images/success.png", "spec/bolt", "spec/bolt/runners", "spec/bolt/runners/rspec_spec.rb", "spec/bolt/runners/test_unit_spec.rb", "README.textile", "LICENSE"]
  s.homepage = %q{http://github.com/marcinbunsch/bolt}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{Bolt is a merge of autotest and mislav/rspactor to produce a lightning fast, configurable and simple to set up autotest clone}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
