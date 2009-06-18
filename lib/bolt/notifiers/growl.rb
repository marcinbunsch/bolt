#
# Bolt::Notifiers::Growl
#
# The Growl Notifier uses Growl to report on test results
# The Growl Notifer is copied from mislav/rspactor growl module
#
# Growl network support implemented by cziko (http://github.com/cziko/)
#
module Bolt
  module Notifiers
    class Growl

      attr_accessor :host, :use_growlnotify

      def initialize(pars = {})
        if Bolt['notifier_host']
          @host = Bolt['notifier_host']
          # load the gem only if required
          begin 
            gem 'ruby-growl'
            require 'ruby-growl'
          rescue ::Gem::LoadError
            puts "** ERROR: Could not start growl network support. Install 'ruby-growl' gem to enable."
            @host = nil
          end
        end
        @use_growlnotify = false
        @use_growlnotify = true if pars[:use_growlnotify] or !@host
      end
    
      # generic notify method
      def notify(title, msg, img, pri = 0)
        if @use_growlnotify
          system("growlnotify -w -n bolt --image #{img} -p #{pri} -m #{msg.inspect} #{title} &") 
        else
          g = ::Growl.new(@host, "bolt", ["notification"])
          g.notify("notification", title, msg, pri)
        end
      end

      # info message
      def info(name, description)
        image_path = File.dirname(__FILE__) + "/../../../images/pending.png"
        notify name, description.to_s, image_path
      end
       
      # message to be displayed when test file is missing
      def test_file_missing(filename)
        image_path = File.dirname(__FILE__) + "/../../../images/failed.png"
        message = "The following test file could not be found: #{filename}"
        notify "Could not find test file", message, image_path
      end
      
      def result(filename, results)
        message = results
        if results.match('example') #rspec
          if results.match('pending')
            icon = 'pending'
          elsif results.match('0 failures')
            icon = 'success'
          else
            icon = 'failed'
          end
        elsif (results.match('0 failures, 0 errors')) # test::unit
          icon = 'success'
        else
          icon = 'failed'
        end
        image_path = File.dirname(__FILE__) + "/../../../images/#{icon}.png"
        notify  "Test results for: #{filename}", message, image_path
      end
      
      def error(name, description)
        image_path = File.dirname(__FILE__) + "/../../../images/failed.png"
        notify name, description.to_s, image_path
      end
      
    end
  end
end
