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
      
      $stdout.puts "** Using #{selected.class} \n"
    end
    
    # Pick a listener to launch
    def runner
      return selected if selected
      
      if Bolt['runner'] and ['test_unit', 'rspec'].include?(Bolt['runner'])
        self.selected= Bolt::Runners::TestUnit.new if Bolt['runner'] == 'test_unit'
        self.selected= Bolt::Runners::RSpec.new if Bolt['runner'] == 'rspec'
        $stdout.puts "** Found 'runner' setting in .bolt"
        return self.selected
      end
      $stdout.puts "** Determining runner... \n"
      self.selected= Bolt::Runners::TestUnit.new
      self.selected= Bolt::Runners::RSpec.new  if File.directory?('spec')
      self.selected
    end
    
  end
end