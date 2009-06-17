require 'bolt/notifier'
require 'bolt/runner'
#
# Bolt::Listener
#
# The Listener waits for files to be saved and when one is found, it launches the finder to match the file with a test
#
module Bolt
  class Listener
    attr_accessor :selected, :notifier, :runner
    
    # Constructor
    def initialize
      # find appropriate listener
      $stdout.puts "** Using #{listener.class} "
      
      # trap the INT signal 
      add_sigint_handler
      
      # attach a notifier
      self.notifier = Bolt::Notifier.new.selected
      
      # attach a mapper
      self.runner = Bolt::Runner.new.selected
      self.runner.notifier = self.notifier
      
      # attach the notifier to listener
      listener.notifier = self.notifier
      
      # attach runner mappings to listener to avoid searching in all files
      listener.mappings = self.runner.class::MAPPINGS
      
      # attach listener wrapper
      listener.parent = self
      
      # display info to user
      notifier.info 'Bolt running', "Bolt is enabled and running in #{Dir.pwd}"
      
      # if in Rails, start environment
      listener.start
      
    end
    
    # handle updated files found by specific listener 
    def handle(updated_files)
      # notifier.spotted(updated_files.first)
      # send them to mapper
      Runners.files = updated_files
      runner.handle(updated_files.first)
      # run appropriate tests in runner
    end

    # Pick a listener to launch
    def listener
      return selected if selected
      # TODO: os identification via RUBY_PLATFORM is flawed as it will return 'java' in jruby. Look for a different solution
      os_string = RUBY_PLATFORM.downcase
      self.selected= Bolt::Listeners::Generic.new      
      self.selected= Bolt::Listeners::Osx.start if os_string.include?("darwin")
      # TODO:
      # self.selected= Bolt::Listeners::Windows.new if os_string.include?("mswin")
      # self.selected= Bolt::Listeners::Linux.new if os_string.include?("linux")
      selected
    end
    
    # capture the INT signal
    def add_sigint_handler
      trap 'INT' do
        $stdout.puts "\n** Exiting Bolt..."
        notifier.info 'Bolt terminated', "Bolt has been terminated"
        exit(0)
      end
    end
   
  end
end