#
# Bolt::Runners::Base
#
# Abstract base class for runners
#
module Bolt
  module Runners
    class Base
      
      # mappings define which folders hold the files that the listener should listen to
      MAPPINGS =  /(\.\/app\/|\.\/lib\/)/
      
      # class map specifies the folders holding classes that can be reloaded
      CLASS_MAP = /(app\/controllers|app\/models|lib\/)/
      
      # do not allow this class to be instantiated
      def initialized
        raise NotImplementedError
      end 
      # /initialized
      
      # handle an updated file
      def handle(filename)
        
        reload filename
        
        puts "=> #{self.class} running test for #{filename}" if Bolt['verbose']
        test_files = translate(filename)
        
        return if test_files == []
        
        puts "==== #{self.class} running: #{ test_files.join(', ')}  ===="
                
        run(test_files)
        
        puts "==== #{self.class} completed run ===="
        
      end
      
      # translate the filename into a test
      def translate(filename)
        
      end
      
      # run the specified test
      def run(test_filename)

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
      
      # get the classname based on file
      def resolve_classname(filename)
        filename.sub('.rb', '').gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
      end
      
      # resolve the class based on filename
      def resolve_class(filename)
        klassname = resolve_classname(filename)
        begin
          return eval(klassname)
        rescue NameError
          return false
        end
      end
      
      # clear the class of methods before reload
      def clear_class(klass)
        begin
          klass.instance_methods.each do |m| 
            next if m.to_s == '__id__'
            next if m.to_s == '__send__'
            begin
              klass.send(:remove_method, m)
            rescue
            end
          end
        rescue NameError
        end
      end
      
      def load_file(filename)
        # load file again to rebuild the class we just ripped apart
        if filename.match(self.class::CLASS_MAP)
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
      end
      
      # force reload of a file/class
      def reload(filename)
        
        # remove the file from list of loaded files
        $".delete(filename)
        $".delete(File.join(Dir.pwd, filename))
        
        # remove methods from class (if present)
        if filename.match(self.class::CLASS_MAP)
          class_filename = filename.sub(self.class::CLASS_MAP, '')
          
          # get the class
          klass = resolve_class(class_filename)

          # remove all methods - don't worry, the reload will bring them back refreshed
          clear_class(klass) if klass

        end

        load_file(filename)
        
      end 
      # /reload
      
    end
  end
end