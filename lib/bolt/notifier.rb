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
      # find appropriate notifier
      notifier
      # present
      $stdout.puts "** Using #{notifier.class} \n"      
    end

    # Pick a listener to launch
    def notifier
      return selected if selected
      

      if Bolt['notifier'] and ['generic', 'growl'].include?(Bolt['notifier'])
        self.selected= Bolt::Notifiers::Growl.new if Bolt['notifier'] == 'growl'
        self.selected= Bolt::Notifiers::Generic.new if Bolt['notifier'] == 'generic'
        self.selected= Bolt::Notifiers::NotifyOsd.new if Bolt['notifier'] == 'notify_send'
        $stdout.puts "** Found 'notifier' setting in .bolt"
        return self.selected
      end
      
      $stdout.puts "** Determining notifier... \n"
      
      # default - growl (if growlnotify is present)
      output = %x[which growlnotify]
      if !Bolt['notifier'] and output.to_s.include?('/growlnotify')
        self.selected= Bolt::Notifiers::Growl.new(:use_growlnotify => true)        
      end
      
      output = %x[which notify-send]
      if !Bolt['notifier'] and output.to_s.include?('/notify-send')
        self.selected= Bolt::Notifiers::NotifyOsd.new     
      end
      
      # default if else fails
      if !selected
        self.selected= Bolt::Notifiers::Generic.new
      end

      selected
    end
   
  end
end
