#
# Bolt::Notifiers::Generic
#
# The Generic Notifier does not do anything, it's for stability
# The Growl Notifer is copied from mislav/rspactor growl module
#
module Bolt
  module Notifiers
    class Growl
    
      # generic notify method
      def notify(title, msg, img, pri = 0)
        system("growlnotify -w -n rspactor --image #{img} -p #{pri} -m #{msg.inspect} #{title} &") 
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