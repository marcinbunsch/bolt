require 'yaml'

# Why Bolt? Cause it's a cool name, that's why :)
module Bolt
  
  @@listener = nil
  
  # Attr writer for Listener
  def self.listener=(listener)
    @@listener = listener
  end
  
  # Attr reader for Listener
  def self.listener
    @@listener
  end
  
  # static location for settings
  @@config = {}
  
  # set a config setting
  def self.set(key, value)
    @@config[key] = value
  end
  
  # retrieve a value for a config setting
  def self.get(key)
    @@config[key]
  end
  
  # convienience accessor
  def self.[](key)
    @@config[key]
  end
  
  # read the .bolt file for configuration
  def self.read_dotfile
    if File.exists?('.bolt')
      parsed_dotfile = YAML.load_file('.bolt')
      @@config.merge!(parsed_dotfile) if parsed_dotfile
      $stdout.puts "** Found .bolt file" if Bolt.verbose?
    end
  end
  
  # read the arguments passed in cli
  def self.read_argv
    ARGV.each do |arg|
      @@config['verbose'] = true if arg == '-v'
    end
  end
  
  # check for verbose execution
  def self.verbose?
    @@config['verbose'] == 'true'
  end
  
  # Trap appropriate signals
  def self.trap_signals
    # ctrl-c should exit
    trap 'INT' do
      $stdout.puts "\n** Exiting Bolt..."
      exit(0)
    end
  end
  
  # load all bolt required files
  def self.load
    $stdout.puts "** Starting Bolt..."
    
    # read the dotfile
    Bolt.read_dotfile
    
    # read the arguments passed
    Bolt.read_argv
    
    # trap signals
    Bolt.trap_signals
    

  end
  
  # start bolt
  def self.start

    self.listener= Bolt::Listener.new
    
    # display info to user
    self.listener.selected.notifier.info 'Bolt running', "Bolt is enabled and running in #{Dir.pwd}"
    
    # if in Rails, start environment
    self.listener.selected.start
  end

  autoload :Runner, File.dirname(__FILE__) + '/bolt/runner'
  autoload :Notifier, File.dirname(__FILE__) + '/bolt/notifier'
  autoload :Listener, File.dirname(__FILE__) + '/bolt/listener'
  
  #
  # Bolt::Listeners
  #
  # Wrapper for specific listeners
  #
  module Listeners
    autoload :Generic, File.dirname(__FILE__) + '/bolt/listeners/generic'
    # autoload :Kqueue, File.dirname(__FILE__) + '/bolt/listeners/kqueue'
    autoload :Osx, File.dirname(__FILE__) + '/bolt/listeners/osx'
  end
  
  #
  # Bolt::Runners
  #
  # Wrapper for specific runners
  #
  module Runners
    @@noticed_files = []
    
    def self.files=(arr)
      @@noticed_files = arr
    end
    
    def self.files
      @@noticed_files
    end
    
    autoload :Base, File.dirname(__FILE__) + '/bolt/runners/base'
    autoload :Cucumber, File.dirname(__FILE__) + '/bolt/runners/cucumber'
    autoload :TestUnit, File.dirname(__FILE__) + '/bolt/runners/test_unit'
    autoload :LegacyTestUnit, File.dirname(__FILE__) + '/bolt/runners/legacy_test_unit'
    autoload :RSpec, File.dirname(__FILE__) + '/bolt/runners/rspec'
  end
    
  #
  # Bolt::Notifiers
  #
  # Wrapper for specific notifier
  #
  module Notifiers
    autoload :Generic, File.dirname(__FILE__) + '/bolt/notifiers/generic'
    autoload :Growl, File.dirname(__FILE__) + '/bolt/notifiers/growl'
    autoload :NotifyOsd, File.dirname(__FILE__) + '/bolt/notifiers/notify_osd'
  end
end
