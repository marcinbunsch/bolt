#
# Bolt::Notifiers::NotifyOsd
#
# The NotifyOsd Notifier uses Notify-OSD to report on test results
#
#
module Bolt
  module Notifiers
    class NotifyOsd

      attr_accessor :host, :use_growlnotify

      def initialize(pars = {})
      end
    
      # generic notify method
      def notify(title, msg, img, pri = 'normal')
        system "notify-send -i #{img} -u #{urg} '#{title}' '#{msg}'"
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

