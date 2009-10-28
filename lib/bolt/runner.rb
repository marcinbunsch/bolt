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
      # find appropriate runner
      runner
      
      $stdout.puts "** Using #{selected.class} \n" if Bolt.verbose?
    end
    
    # Pick a runner
    def self.pick
      if Bolt['runner'] and ['legacy_test_unit', 'test_unit', 'rspec', 'cucumber'].include?(Bolt['runner'])
        $stdout.puts "** Found 'runner' setting in .bolt" if Bolt.verbose?
        return Bolt['runner']
      end      
      $stdout.puts "** Determining runner... \n" if Bolt.verbose?
      return 'mixed'  if File.directory?('spec')
      'test_unit'
    end
    
    # Get a Runner instance
    def runner
      return selected if selected
      
      picked = self.class.pick
      self.selected= Bolt::Runners::LegacyTestUnit.new if picked == 'legacy_test_unit'
      self.selected= Bolt::Runners::TestUnit.new if picked == 'test_unit'
      self.selected= Bolt::Runners::RSpec.new if picked == 'rspec'
      self.selected= Bolt::Runners::Cucumber.new if picked == 'cucumber'
      self.selected= Bolt::Runners::Mixed.new if picked == 'mixed'
      self.selected
    end
    
  end
end