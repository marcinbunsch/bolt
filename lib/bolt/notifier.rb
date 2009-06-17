#
# Bolt::Notifier
#
# The Notifier sends notification of the test results to the user
#
module Bolt
  class Notifier
    attr_accessor :selected
    
    # Constructor
    def initialize 
      # find appropriate listener
      $stdout.puts "** Using #{notifier.class} \n"

      # launch appropriate listener      
      # notifier.new
      
    end

    # Pick a listener to launch
    def notifier
      return selected if selected      
      self.selected= Bolt::Notifiers::Generic.new 
      # growl
      output = %x[which growlnotify]
      if output.to_s.include?('/growlnotify')
        self.selected= Bolt::Notifiers::Growl.new
      end
      #self.selected= Bolt::Listeners::Generic
      # self.selected= Bolt::Listeners::OSX if os_string.include?("darwin")
      #self.selected= Bolt::Listeners::Windows if os_string.include?("mswin")
      #self.selected= Bolt::Listeners::Linux if os_string.include?("linux")
      selected
    end
   
  end
end