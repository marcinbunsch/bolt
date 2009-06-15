#
# Bolt::Notifiers::Generic
#
# The Generic Notifier does not do anything, it's for stability
#
module Bolt
  module Notifiers
    class Generic
  
      # info message
      def info(name, description)
      end
       
      # message to be displayed when test file is missing
      def test_file_missing(filename)
      end
      
      def result(filename, results)
      end
      
      def error(name, description)
      end
      
    end
  end
end