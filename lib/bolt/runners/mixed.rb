#
# Bolt::Runners::Mixed
#
# The Mixed Runner uses the rspec and Test::Unit runners at the same time
#
module Bolt
  module Runners
    class Mixed < Bolt::Runners::Base
      
      # mappings define which folders hold the files that the listener should listen to
      MAPPINGS =  /(\.\/app\/|\.\/lib\/|\.\/spec\/controllers|\.\/spec\/models|\.\/spec\/helpers|\.\/spec|\.\/test\/functional|\.\/test\/unit)/
      
      # class map specifies the folders holding classes that can be reloaded
      CLASS_MAP = /(test\/functional\/|test\/unit\/|app\/controllers\/|app\/models\/|app\/helpers\/|lib\/)/
      
      # accesors
      attr_accessor :notifier, :test_io
      
      # mapping is a copied and modified version of mislav/rspactor Inspector#translate
      def translate(file)
        [file]
      end
      
      # run the appropriate test
      def run(files)
        files = files.first
        if !@test_unit_runner
          @test_unit_runner ||= Bolt::Runners::RSpec.new 
          @test_unit_runner.notifier = notifier
        end
        if !@rspec_runner
          @rspec_runner ||= Bolt::Runners::TestUnit.new 
          @rspec_runner.notifier = notifier
        end
        
        test_unit = @test_unit_runner.translate([files])
        @test_unit_runner.run(test_unit) if test_unit != []
        rspec = @rspec_runner.translate(files)
        @rspec_runner.run(rspec) if rspec != []
      end
      
    end
  end
end