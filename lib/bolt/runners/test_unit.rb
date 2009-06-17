require 'test/unit'
require 'test/unit/ui/console/testrunner'
#
# Bolt::Runners::TestUnit
#
# The TestUnit Runners maps the filename to the appropriate test
#
module Bolt
  module Runners
    class TestUnit
      
      MAPPINGS =  /(\.\/app\/|\.\/lib\/|\.\/test\/functional|\.\/test\/unit)/
      
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
      
      # handle specified file
      def handle(file)
        
        # force reload of file
        $".delete(file)
        $".delete(File.join(Dir.pwd, file))
        
        # reload tests and classes
        if file.match(/(test\/functional|test\/unit|app\/controllers|app\/models|lib\/)/)
          puts '=================='
          klassname = file.sub('test/unit/', '').sub('test/functional/', '').sub('app/controllers/', '').sub('app/models/', '').sub('lib/', '')
          klass_to_be_tested = klassname.sub('.rb', '').gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
          

          # remove all methods - don't worry, the reload will bring them back refreshed
          begin
            klass = eval(klass_to_be_tested)
            klass.instance_methods.each { |m| 
              begin
                klass.send(:remove_method, m)
              rescue
              end
            }
          rescue NameError
          end
        end

        if file.include?('app/controllers') or file.include?('app/models') or file.include?('lib/')
          begin
            filename = File.join(Dir.pwd, file)
            filename << '.rb' if !filename.match('.rb')
            load filename
          rescue LoadError
            notifier.error("Error in #{file}", $!)
            return []
          rescue ArgumentError
            notifier.error("Error in #{file}", $!)
            return []
          end
        end
      
        puts '=> Test::Unit running test for ' + file
        test_files = translate(file)
        
        puts '==== Test::Unit running: ' + test_files.join(', ') + ' ===='
        
        run(test_files) if test_files != []
        
        puts '==== Test::Unit completed run ===='
        
      end
      
      # check whether file exists
      def file_verified?(filename)
        if !File.exists?(filename)
          notifier.test_file_missing(filename)
          puts "=> ERROR: could not find test file: #{filename}"
          return false
        end
        return true
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
          puts "=> NOTICE: could not find test file for: #{file}"
        end
        # puts candidates.inspect
        candidates
      end
      
      def run(files)
        file = files.first
        puts "** Running #{file}"
        # make sure that you reload the test file
        #load file
        #contents = File.open(file).read
        # puts contents
        #eval contents
        
        # This is Rails' String#camelcase
        klassname = file.sub('test/functional/', '').sub('test/unit/', '')
        test_class = klassname.sub('.rb', '').gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
        
        # create dummy wrapper modules if test is in subfolder
        test_class.split('::').each do |part|
          eval "module ::#{part}; end" if !part.match('Test')
        end
        
        $".delete(file)
        
        #(defined?(ActiveRecord::Base) ? ActiveRecord::Base.instance_eval { subclasses }.each { |c| c.reset_column_information } : nil)
        #(defined?(ActiveSupport::Dependencies) ? ActiveSupport::Dependencies.clear : nil)
        
        begin
          require file
        rescue LoadError
          notifier.error("Error in #{file}", $!)
          return
        rescue ArgumentError
          notifier.error("Error in #{file}", $!)
          return
        end
        
        # TODO: change that to run multiple suites
        #klass = Kernel.const_get(test_class) - this threw errors
        klass = eval(test_class)
        
        Test::Unit::UI::Console::TestRunner.run(klass)
      
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