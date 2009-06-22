require 'spec'
require 'stringio'
#
# Bolt::Runners::Rspec
#
# The Rspec Runner maps the filename to the appropriate spec
#
module Bolt
  module Runners
    class RSpec < Bolt::Runners::Base
      
      # mappings define which folders hold the files that the listener should listen to
      MAPPINGS =  /(\.\/app\/|\.\/lib\/|\.\/spec\/controllers|\.\/spec\/models|\.\/spec)/
      
      # class map specifies the folders holding classes that can be reloaded
      CLASS_MAP = /(app\/controllers\/|app\/models\/|lib\/)/
      
      # accesors
      attr_accessor :notifier, :test_io
      
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
      
      # run the appropriate test
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