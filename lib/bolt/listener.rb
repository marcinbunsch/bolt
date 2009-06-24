require File.dirname(__FILE__) + '/notifier'
require File.dirname(__FILE__) + '/runner'
#
# Bolt::Listener
#
# The Listener waits for files to be saved and when one is found, it launches the finder to match the file with a test
#
module Bolt
  class Listener
    attr_accessor :selected, :notifier, :runner
    
    # Constructor
    # TODO: move most of this code to Bolt.start
    def initialize
      # find appropriate listener
      listener
      
      $stdout.puts "** Using #{listener.class} " if Bolt.verbose?
      
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
      
    end
    
    # handle updated files found by specific listener 
    def handle(updated_files)
      # notifier.spotted(updated_files.first)
      # send them to mapper
      Runners.files = updated_files
      runner.handle(updated_files.first)
      # run appropriate tests in runner
    end

    def os
      # TODO: os identification via RUBY_PLATFORM is flawed as it will return 'java' in jruby. Look for a different solution
      os_string = RUBY_PLATFORM.downcase
    end
    
    # Pick a listener to launch
    def listener
      return selected if selected
      
      if Bolt['listener'] and ['generic', 'osx'].include?(Bolt['listener'])
        self.selected= Bolt::Listeners::Generic.new if Bolt['listener'] == 'generic'
        self.selected= Bolt::Listeners::Osx.start if Bolt['listener'] == 'osx'
        $stdout.puts "** Found listener setting in .bolt" if Bolt.verbose?
        return self.selected
      end
        
      $stdout.puts "** Determining listener..." if Bolt.verbose?
      
      os_string = os

      self.selected= Bolt::Listeners::Generic.new      
      self.selected= Bolt::Listeners::Osx.start if os_string.include?("darwin")
      # TODO:
      # self.selected= Bolt::Listeners::Windows.new if os_string.include?("mswin")
      # self.selected= Bolt::Listeners::Linux.new if os_string.include?("linux")
      selected
    end
   
  end
end