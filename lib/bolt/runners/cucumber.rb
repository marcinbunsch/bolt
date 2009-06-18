#
# Bolt::Runners::Cucumber
#
# The Cucumber Runner maps the filename to the appropriate feature
#
module Bolt
  module Runners
    class Cucumber
      
      MAPPINGS =  /(\.\/app\/|\.\/lib\/|\.\/features\/)/
      
      attr_accessor :notifier, :test_io
      
      @@mother = nil
      
      def self.mother=(step_mother)
        @@mother = step_mother
      end
      
      def self.mother
        @@mother
      end
      
      def initialize
      end
      
      # handle specified file
      def handle(filename)
        puts '=> Cucumber running test for ' + filename
        
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
          
        puts '==== Cucumber running: ' + test_files.join(', ') + ' ===='
        
        run(test_files)
        
        puts '==== Cucumber completed run ===='
      end
      
      # check whether file exists
      def file_verified?(filename)
        if !File.exists?(filename)
          notifier.test_file_missing(filename)
          puts "=> ERROR: could not find feature file: #{filename}"
          return false
        end
        return true
      end
      
      # mapping is a copied and modified version of mislav/rspactor Inspector#translate
      def translate(file)
        
        return ['features/posts.feature']
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
          puts "=> NOTICE: could not find feature file for: #{file}"
        end

        candidates
      end
      
      def run(files)
        file = files.first
                
        # redirect spec output to StringIO
        io = StringIO.new
        
        $stdout, old = io, $stdout
        # refresh the loaded test file
        #$".delete(file)
        #require file
        Bolt::Runners::Cucumber.mother.reload_definitions! if Bolt::Runners::Cucumber.mother
        
        ::Cucumber::Cli::Main.execute([file])

        Bolt::Runners::Cucumber.mother.clear_steps_and_scenarios!
        # read the buffer
        result = io.string.to_s.dup

        $stdout = old
                
        # send buffer to stdout
        puts result
        
        last_three = result.split("\n")[-3..-1].join(' ')
        last_three = last_three.gsub("\e[32m", '').gsub("\e[0m", '').gsub("\e[36m", '').gsub("\e[31m", '') # get ri of the color codes
        
        # sent result to notifier
        notifier.result(file, last_three)
        
      end
      
    end
  end
end

require 'cucumber'
require 'cucumber/rspec_neuter'
require 'cucumber/cli/main'
# Time to hack around a bit
module Cucumber
  module StepMother
    
    def reload_definitions!
      step_definitions.clear
      #Dir['features/step_definitions/*'].map do |f| 
        #require "features/step_definitions/#{File.basename(f)}"
      #end
    end
    
    def clear_steps_and_scenarios!
      steps.clear
      scenarios.clear
    end  
  end
  
  module Cli
    class Main

      def self.execute(args)
        instance = new(args)
        instance.execute!(@step_mother)
        Bolt::Runners::Cucumber.mother = @step_mother
        instance
      end
      
    end
  end
end