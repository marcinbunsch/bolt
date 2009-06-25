require 'spec'
require File.dirname(__FILE__) + '/../../lib/bolt.rb'

describe Bolt::Listener do

  it 'should select appropriate listener' do
    Bolt.set('listener', 'generic')
    instance = Bolt::Listener.new
    instance.listener.class.should == Bolt::Listeners::Generic
    instance.stub(:os).and_return('unknown system')
    instance.os.should == 'unknown system'
    instance.selected = nil
    instance.selected.should == nil
    instance.listener.class.should == Bolt::Listeners::Generic
  end
  
end