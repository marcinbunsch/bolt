require 'spec'
require 'stringio'
#
# Bolt::Runners::Rspec
#
# The Rspec Runner maps the filename to the appropriate spec
#
module Bolt
  module Runners
    class RSpec
      
      MAPPINGS =  /(\.\/app\/|\.\/lib\/|\.\/spec\/controllers|\.\/spec\/models|\.\/spec)/
      
      attr_accessor :notifier, :test_io
      
      def initialize
      end
      
      # handle specified file
      def handle(filename)
        puts '=> Rspec running test for ' + filename
        
        # force reload of file
        $".delete(filename)
        $".delete(File.join(Dir.pwd, filename))
        file = filename
        # reload tests and classes
        if file.match(/(app\/controllers|app\/models|lib\/)/)
          puts '=================='
          klassname = file.sub('app/controllers/', '').sub('app/models/', '').sub('lib/', '')
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

        if filename.include?('app/controllers') or filename.include?('app/models') or filename.include?('lib/')
          begin
            require File.join(Dir.pwd, filename)
          rescue LoadError
            notifier.error("Error in #{filename}", $!)
            return false
          rescue ArgumentError
            notifier.error("Error in #{filename}", $!)
            return false
          end
        end
        
        test_files = translate(filename)
        
        return if test_files == []
          
        puts '==== Rspec running: ' + test_files.join(', ') + ' ===='
        
        run(test_files)
        
        puts '==== Rspec completed run ===='
      end
      
      # check whether file exists
      def file_verified?(filename)
        if !File.exists?(filename)
          notifier.test_file_missing(filename)
          puts "=> ERROR: could not find spec file: #{filename}"
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
            test_filename = file.sub('.rb', '_spec.rb').sub('app/controllers', 'spec/controllers')
          when %r:^app/models/:
            test_filename = "spec/models/#{basename.sub('.rb', '_spec.rb')}"
          when %r:^app/views/:
            file = file.sub('app/views/', '')
            directory = file.split('/')[0..-2].compact.join('/')
            test_filename = "spec/controllers/#{directory}_controller_spec.rb"
          when %r:^spec/:
            test_filename = file
          when %r:^lib/:
            # map libs to straight specs
            test_filename = "spec/#{file.sub('lib/', '').sub('.rb', '_spec.rb')}"
          when 'config/routes.rb'
            test_filename = "spec/controllers/#{basename.sub('.rb', '_spec.rb')}"
          when 'config/database.yml', 'db/schema.rb'
            #candidates << 'models'
          else
            #
        end
        if test_filename and file_verified?(test_filename)
          candidates << test_filename
        end
        if candidates == []
          puts "=> NOTICE: could not find spec file for: #{file}"
        end

        candidates
      end
      
      def run(files)
        file = files.first
        
        require 'spec'
        
        # redirect spec output to StringIO
        io = StringIO.new
        ::Spec::Runner.use(::Spec::Runner::OptionParser.new($stderr, io).options)

        # refresh the loaded test file
        $".delete(file)
        require file
        
        # run the tests in the Spec::Runner
        ::Spec::Runner::CommandLine.run
        
        # recreate the reporter to refresh the example count
        ::Spec::Runner::Reporter.new(::Spec::Runner.options)
        
        # remove all examples up to date
        ::Spec::Runner.options.example_groups.each { |g| ::Spec::Runner.options.remove_example_group(g) }
                
        # read the buffer
        result = io.string.to_s.dup
        
        # send buffer to stdout
        puts result
        
        # sent result to notifier
        notifier.result(file, result.split("\n").compact.last)
        
      end
      
    end
  end
end