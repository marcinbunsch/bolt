#
# Bolt::Runner
#
# The Runner maps the changed file to the appropriate test file and runs it
#
module Bolt
  class Runner
    attr_accessor :selected, :notifier
    
    # Constructor
    def initialize 
      # find appropriate listener
      $stdout.puts "** Using #{runner.class}... \n"
    end
    
    # Pick a listener to launch
    def runner
      return selected if selected
      # TODO: os identification via RUBY_PLATFORM is flawed as it will return 'java' in jruby. Look for a different solution
      
      self.selected= Bolt::Runners::TestUnit.new
      self.selected= Bolt::Runners::RSpec.new if File.directory?('spec')
      selected
    end
    
  end
end