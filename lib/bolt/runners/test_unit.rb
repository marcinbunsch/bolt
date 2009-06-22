require 'test/unit'
require 'test/unit/ui/console/testrunner'
#
# Bolt::Runners::TestUnit
#
# The TestUnit Runners maps the filename to the appropriate test
#
module Bolt
  module Runners
    class TestUnit < Bolt::Runners::Base
      
      # mappings define which folders hold the files that the listener should listen to
      MAPPINGS =  /(\.\/app\/|\.\/lib\/|\.\/test\/functional|\.\/test\/unit)/
      
      # class map specifies the folders holding classes that can be reloaded
      CLASS_MAP = /(test\/functional\/|test\/unit\/|app\/controllers\/|app\/models\/|lib\/)/
      
      attr_accessor :notifier, :test_io
      
      def initialize
        fix_test_unit_io
      end
      
      def fix_test_unit_io
        # Test::Unit stdio capture workaround, taken from Roman2K-rails-test-serving
        self.test_io = StringIO.new
        io = test_io
        Test::Unit::UI::Console::TestRunner.class_eval do
          alias_method :old_initialize, :initialize
          def initialize(suite, output_level, io=Thread.current["test_runner_io"])
            old_initialize(suite, output_level, io)
          end
        end
        Thread.current["test_runner_io"] = io
      end
    
      # mapping is a copied and modified version of mislav/rspactor Inspector#translate
      def translate(file)
        
        basename = File.basename(file)
        candidates = []
        test_filename = nil
        case file
          when %r:^app/controllers/:
            test_filename = file.sub('.rb', '_test.rb').sub('app/controllers', 'test/functional')
          when %r:^app/models/:
            test_filename = "test/unit/#{basename.sub('.rb', '_test.rb')}"
          when %r:^app/views/:
            file = file.sub('app/views/', '')
            directory = file.split('/')[0..-2].compact.join('/')
            test_filename = "test/functional/#{directory}_controller_test.rb"
          when %r:^test/:
            test_filename = file
          when %r:^lib/:
            # map libs to units
            test_filename = "test/unit/#{file.sub('lib/', '').sub('.rb', '_test.rb')}"
          when 'config/routes.rb'
            test_filename = "test/functional/#{basename.sub('.rb', '_test.rb')}"
            #candidates << 'controllers' << 'helpers' << 'views'
          when 'config/database.yml', 'db/schema.rb'
            #candidates << 'models'
          else
            #
        end
        if test_filename and file_verified?(test_filename)
          candidates << test_filename
        end
        if candidates == []
          puts "=> NOTICE: could not find test file for: #{file}" if Bolt['verbose']
        end
        # puts candidates.inspect
        candidates
      end
      
      def run(files)
        file = files.first
        puts "** Running #{file}"
        
        class_filename = file.sub(self.class::CLASS_MAP, '')
        
        # get the class
        test_class = resolve_classname(class_filename)
        
        # create dummy wrapper modules if test is in subfolder
        test_class.split('::').each do |part|
          eval "module ::#{part}; end" if !part.match('Test')
        end
        
        # TODO: make this reload use load_file
        $".delete(file)
        
        begin
          require file
        rescue LoadError
          notifier.error("Error in #{file}", $!)
          puts $!
          return
        rescue ArgumentError
          notifier.error("Error in #{file}", $!)
          puts $!
          return
        rescue SyntaxError
          notifier.error("Error in #{file}", $!)
          puts $!
          return
        end
        
        # TODO: change that to run multiple suites
        #klass = Kernel.const_get(test_class) - this threw errors
        klass = eval(test_class)
        
        Test::Unit::UI::Console::TestRunner.run(klass)
        Test::Unit.run = false
        
        # Invoke method to test that writes to stdout.
        result = test_io.string.to_s.dup

        # clear the buffer 
        test_io.truncate(0)
        
        # sent result to notifier
        notifier.result(file, result.split("\n").compact.last)

        # sent result to stdio
        puts result
        
      end
      
    end
  end
end