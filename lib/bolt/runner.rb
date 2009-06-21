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
      
      $stdout.puts "** Using #{selected.class} \n" if Bolt['verbose']
    end
    
    # Pick a listener to launch
    def runner
      return selected if selected
      
      if Bolt['runner'] and ['test_unit', 'rspec', 'cucumber'].include?(Bolt['runner'])
        self.selected= Bolt::Runners::TestUnit.new if Bolt['runner'] == 'test_unit'
        self.selected= Bolt::Runners::RSpec.new if Bolt['runner'] == 'rspec'
        self.selected= Bolt::Runners::Cucumber.new if Bolt['runner'] == 'cucumber'
        $stdout.puts "** Found 'runner' setting in .bolt" if Bolt['verbose']
        return self.selected
      end
      $stdout.puts "** Determining runner... \n" if Bolt['verbose']
      self.selected= Bolt::Runners::TestUnit.new
      self.selected= Bolt::Runners::RSpec.new  if File.directory?('spec')
      self.selected
    end
    
  end
end