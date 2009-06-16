# Why Bolt? Cause it's a cool name, that's why :)
module Bolt
  autoload :Mapper, 'bolt/mapper'
  autoload :Runner, 'bolt/runner'
  autoload :Notifier, 'bolt/notifier'
  autoload :Listener, 'bolt/listener'
  
  #
  # Bolt::Listeners
  #
  # Wrapper for specific listeners
  #
  module Listeners
    autoload :Generic, 'bolt/listeners/generic'
    autoload :Kqueue, 'bolt/listeners/kqueue'
    autoload :Osx, 'bolt/listeners/osx'
  end
  
  #
  # Bolt::Runners
  #
  # Wrapper for specific runners
  #
  module Runners
    @@noticed_files = []
    
    def self.files=(arr)
      @@noticed_files = arr
    end
    
    def self.files
      @@noticed_files
    end
    
    autoload :TestUnit, 'bolt/runners/test_unit'
    autoload :RSpec, 'bolt/runners/rspec'
  end
    
  #
  # Bolt::Notifiers
  #
  # Wrapper for specific notifier
  #
  module Notifiers
    autoload :Generic, 'bolt/notifiers/generic'
    autoload :Growl, 'bolt/notifiers/growl'
  end
end