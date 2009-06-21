require 'find'
#
# Bolt::Listeners::Generic
#
# The generic Listener, which polls the files after a specific interval
#
module Bolt
  module Listeners
    class Generic
      attr_accessor :files, :interval, :busy, :notifier, :parent, :mappings
      
      def initialize
        self.interval = 1 # decrease the CPU load by increasing the interval
        self.busy     = false
      end 
      
      def start
        puts "** #{self.class} is scanning for files... " if Bolt['verbose']
        # build a file collection
        find_files
        puts "** #{self.class} watching #{files.size} files... "
        wait  
      end
      
      # source: ZenTest/autotest.rb
      def wait
        Kernel.sleep self.interval until check_files
      end
      
      # check files to find these that have changed
      def check_files
        return if busy # if working on something already, skip the iteration
        updated = []
        files.each do |filename, mtime| 
          current_mtime = File.stat(filename).mtime
          if current_mtime != mtime  
            updated << filename
            # update the mtime in file registry so we it's only send once
            files[filename] = current_mtime
            $stdout.puts ">> Spotted change in #{filename}" if Bolt['verbose']
          end
        end
        parent.handle(updated) if updated != []
        false
      end
       
      ##
      # Find the files to process, ignoring temporary files, source
      # configuration management files, etc., and return a Hash mapping
      # filename to modification time.
      # source: ZenTest/autotest.rb
      def find_files
        result = {}
        targets = ['.'] # start simple
        targets.each do |target|
          order = []
          Find.find(target) do |f|
            
            in_mappings = f =~ self.mappings
            next if in_mappings.nil?
            next if test ?d, f
            next if f =~ /(swp|~|rej|orig)$/ # temporary/patch files
            next if f =~ /\/\.?#/            # Emacs autosave/cvs merge files

            filename = f.sub(/^\.\//, '')
            
            result[filename] = File.stat(filename).mtime rescue next
          end
        end
        
        self.files = result
      end
      
    end 
  end
end