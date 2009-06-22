# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{bolt}
  s.version = "0.2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Marcin Bunsch"]
  s.date = %q{2009-06-22}
  s.default_executable = %q{bolt}
  s.email = %q{marcin@applicake.com}
  s.executables = ["bolt"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.textile"
  ]
  s.files = [
    ".bolt",
     ".bolt.sample",
     ".document",
     "LICENSE",
     "README.textile",
     "Rakefile",
     "bin/bolt",
     "images/LICENSE",
     "images/failed.png",
     "images/pending.png",
     "images/success.png",
     "lib/bolt.rb",
     "lib/bolt/adapters/rails.rb",
     "lib/bolt/listener.rb",
     "lib/bolt/listeners/generic.rb",
     "lib/bolt/listeners/osx.rb",
     "lib/bolt/notifier.rb",
     "lib/bolt/notifiers/generic.rb",
     "lib/bolt/notifiers/growl.rb",
     "lib/bolt/notifiers/notify_osd.rb",
     "lib/bolt/runner.rb",
     "lib/bolt/runners/base.rb",
     "lib/bolt/runners/cucumber.rb",
     "lib/bolt/runners/rspec.rb",
     "lib/bolt/runners/test_unit.rb",
     "spec/bolt/runners/rspec_spec.rb",
     "spec/bolt/runners/test_unit_spec.rb"
  ]
  s.homepage = %q{http://github.com/marcinbunsch/bolt}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{Bolt is a merge of autotest, mislav/rspactor and rails_server_testing to produce a lightning fast, configurable and simple to set up autotest clone}
  s.test_files = [
    "spec/bolt/runners/rspec_spec.rb",
     "spec/bolt/runners/test_unit_spec.rb",
     "test/unit/bolt/listener_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
