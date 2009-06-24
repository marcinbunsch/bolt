#
# Bolt::Listeners::OSX
#
# OSX-specific Listener, using solution taken from mislav/rspactor listener.rb
#
# TODO: I have Mac OS X 10.4 and this works only in OS X 10.5. Which means I haven't been able to test it and adapt it.
#
module Bolt
  module Listeners
    class Osx

      attr_reader :last_check, :callback, :valid_extensions

      def initialize(valid_extensions = nil)
        @valid_extensions = %w(rb erb builder haml rhtml rxml yml conf opts)
        timestamp_checked

        @callback = lambda do |stream, ctx, num_events, paths, marks, event_ids|
          changed_files = extract_changed_files_from_paths(split_paths(paths, num_events))
          timestamp_checked
          yield changed_files unless changed_files.empty?
        end
        run(Dir.pwd)
      end
      
      def self.start
        begin
          require 'osx/foundation'         
        rescue LoadError
          puts "** Could not load osx/foundation. RubyCocoa not installed? Falling back to Bolt::Listeners::Generic" if Bolt['verbose']
          return Bolt::Listeners::Generic.new
        end
        
        begin
          OSX.require_framework '/System/Library/Frameworks/CoreServices.framework/Frameworks/CarbonCore.framework'
          return self.new
        rescue NameError
          puts "** There was an error loading Bolt::Listeners::Osx. Falling back to Bolt::Listeners::Generic" if Bolt['verbose']
          return Bolt::Listeners::Generic.new
        end
      end

      def run(directories)
        dirs = Array(directories)
        stream = OSX::FSEventStreamCreate(OSX::KCFAllocatorDefault, callback, nil, dirs, OSX::KFSEventStreamEventIdSinceNow, 0.5, 0)
        unless stream
          $stderr.puts "Failed to create stream"
          exit(1)
        end

        OSX::FSEventStreamScheduleWithRunLoop(stream, OSX::CFRunLoopGetCurrent(), OSX::KCFRunLoopDefaultMode)
        unless OSX::FSEventStreamStart(stream)
          $stderr.puts "Failed to start stream"
          exit(1)
        end

        begin
          OSX::CFRunLoopRun()
        rescue Interrupt
          OSX::FSEventStreamStop(stream)
          OSX::FSEventStreamInvalidate(stream)
          OSX::FSEventStreamRelease(stream)
        end
      end

      def timestamp_checked
        @last_check = Time.now
      end

      def split_paths(paths, num_events)
        paths.regard_as('*')
        rpaths = []
        num_events.times { |i| rpaths << paths[i] }
        rpaths
      end

      def extract_changed_files_from_paths(paths)
        changed_files = []
        paths.each do |path|
          next if ignore_path?(path)
          Dir.glob(path + "*").each do |file|
            next if ignore_file?(file)
            changed_files << file if file_changed?(file)
          end
        end
        changed_files
      end

      def file_changed?(file)
        File.stat(file).mtime > last_check
      rescue Errno::ENOENT
        false
      end

      def ignore_path?(path)
        path =~ /(?:^|\/)\.(git|svn)/
      end

      def ignore_file?(file)
        File.basename(file).index('.') == 0 or not valid_extension?(file)
      end

      def file_extension(file)
        file =~ /\.(\w+)$/ and $1
      end

      def valid_extension?(file)
        valid_extensions.nil? or valid_extensions.include?(file_extension(file))
      end

     
    end 
  end
end